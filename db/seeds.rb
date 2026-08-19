# Seed data for local development.
#
# Builds one award ceremony with categories and nominees, a pool on that
# ceremony, and two users -- one with a completed entry, one without -- so every
# route in the app has something to render.
#
# Idempotent: safe to run repeatedly.

CEREMONY = {
  name: 'The 90th Academy Awards',
  locks_at: 1.week.from_now,
  categories: {
    'Best Picture' => ['The Shape of Water', 'Get Out', 'Lady Bird', 'Dunkirk'],
    'Best Director' => ['Guillermo del Toro', 'Jordan Peele', 'Greta Gerwig', 'Christopher Nolan'],
    'Best Actor' => ['Gary Oldman', 'Daniel Day-Lewis', 'Timothee Chalamet', 'Denzel Washington'],
    'Best Actress' => ['Frances McDormand', 'Sally Hawkins', 'Saoirse Ronan', 'Margot Robbie']
  }
}.freeze

ceremony = AwardCeremony.find_or_initialize_by(name: CEREMONY[:name])
ceremony.locks_at = CEREMONY[:locks_at]
ceremony.save!

CEREMONY[:categories].each do |category_name, nominee_names|
  category = ceremony.categories.find_or_create_by!(name: category_name)

  nominee_names.each_with_index do |nominee_name, index|
    nominee = category.nominees.find_or_initialize_by(name: nominee_name)
    nominee.winner = index.zero? # first nominee in each category wins
    nominee.save!
  end
end

pool = Pool.find_or_create_by!(award_ceremony: ceremony)

# A user with a full set of picks -- exercises entries#show and #edit, and Entry#score.
player = User.find_or_initialize_by(email: 'player@example.com')
player.password = 'password'
player.save!

entry = Entry.find_or_initialize_by(pool: pool, user: player)
if entry.new_record?
  entry.picks = ceremony.categories.map do |category|
    Pick.new(category: category, nominee: category.nominees.first)
  end
  entry.save!
end

# A user with no entry -- exercises home#index and the entries#new flow.
newcomer = User.find_or_initialize_by(email: 'newcomer@example.com')
newcomer.password = 'password'
newcomer.save!

puts <<~SUMMARY
  Seeded:
    ceremony   #{ceremony.name} (locks #{ceremony.locks_at.strftime('%Y-%m-%d %H:%M')})
    categories #{ceremony.categories.count}
    nominees   #{Nominee.joins(:category).where(categories: { award_ceremony_id: ceremony.id }).count}
    pool       ##{pool.id}
    entry      ##{entry.id} for #{player.email} (score #{entry.score}/#{ceremony.categories.count})

  Sign in with:
    player@example.com / password     (has an entry)
    newcomer@example.com / password   (no entry)
SUMMARY
