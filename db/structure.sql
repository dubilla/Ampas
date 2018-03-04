--
-- PostgreSQL database dump
--

-- Dumped from database version 10.1
-- Dumped by pg_dump version 10.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: award_ceremonies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE award_ceremonies (
    id integer NOT NULL,
    name text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    locks_at timestamp without time zone
);


--
-- Name: award_ceremonies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE award_ceremonies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: award_ceremonies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE award_ceremonies_id_seq OWNED BY award_ceremonies.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE categories (
    id integer NOT NULL,
    name text,
    award_ceremony_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE categories_id_seq OWNED BY categories.id;


--
-- Name: entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE entries (
    id integer NOT NULL,
    pool_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE entries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE entries_id_seq OWNED BY entries.id;


--
-- Name: nominees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE nominees (
    id integer NOT NULL,
    name text,
    category_id integer,
    winner boolean
);


--
-- Name: nominees_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nominees_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nominees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nominees_id_seq OWNED BY nominees.id;


--
-- Name: picks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE picks (
    id integer NOT NULL,
    entry_id integer,
    nominee_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    category_id integer
);


--
-- Name: picks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE picks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: picks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE picks_id_seq OWNED BY picks.id;


--
-- Name: pools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE pools (
    id integer NOT NULL,
    award_ceremony_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: pools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pools_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pools_id_seq OWNED BY pools.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: award_ceremonies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY award_ceremonies ALTER COLUMN id SET DEFAULT nextval('award_ceremonies_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);


--
-- Name: entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY entries ALTER COLUMN id SET DEFAULT nextval('entries_id_seq'::regclass);


--
-- Name: nominees id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nominees ALTER COLUMN id SET DEFAULT nextval('nominees_id_seq'::regclass);


--
-- Name: picks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY picks ALTER COLUMN id SET DEFAULT nextval('picks_id_seq'::regclass);


--
-- Name: pools id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pools ALTER COLUMN id SET DEFAULT nextval('pools_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: award_ceremonies award_ceremonies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY award_ceremonies
    ADD CONSTRAINT award_ceremonies_pkey PRIMARY KEY (id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: entries entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY entries
    ADD CONSTRAINT entries_pkey PRIMARY KEY (id);


--
-- Name: nominees nominees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nominees
    ADD CONSTRAINT nominees_pkey PRIMARY KEY (id);


--
-- Name: picks picks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY picks
    ADD CONSTRAINT picks_pkey PRIMARY KEY (id);


--
-- Name: pools pools_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pools
    ADD CONSTRAINT pools_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_categories_on_award_ceremony_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_on_award_ceremony_id ON categories USING btree (award_ceremony_id);


--
-- Name: index_entries_on_pool_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entries_on_pool_id ON entries USING btree (pool_id);


--
-- Name: index_entries_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entries_on_user_id ON entries USING btree (user_id);


--
-- Name: index_nominees_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_nominees_on_category_id ON nominees USING btree (category_id);


--
-- Name: index_picks_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_picks_on_category_id ON picks USING btree (category_id);


--
-- Name: index_picks_on_entry_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_picks_on_entry_id ON picks USING btree (entry_id);


--
-- Name: index_picks_on_nominee_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_picks_on_nominee_id ON picks USING btree (nominee_id);


--
-- Name: index_pools_on_award_ceremony_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pools_on_award_ceremony_id ON pools USING btree (award_ceremony_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: nominees fk_rails_3295d19bd4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nominees
    ADD CONSTRAINT fk_rails_3295d19bd4 FOREIGN KEY (category_id) REFERENCES categories(id);


--
-- Name: picks fk_rails_42358aa0a9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY picks
    ADD CONSTRAINT fk_rails_42358aa0a9 FOREIGN KEY (entry_id) REFERENCES entries(id);


--
-- Name: categories fk_rails_53b715888d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT fk_rails_53b715888d FOREIGN KEY (award_ceremony_id) REFERENCES award_ceremonies(id);


--
-- Name: picks fk_rails_78f64222e2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY picks
    ADD CONSTRAINT fk_rails_78f64222e2 FOREIGN KEY (nominee_id) REFERENCES nominees(id);


--
-- Name: pools fk_rails_7dd1327a40; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pools
    ADD CONSTRAINT fk_rails_7dd1327a40 FOREIGN KEY (award_ceremony_id) REFERENCES award_ceremonies(id);


--
-- Name: entries fk_rails_99dc12d4fd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY entries
    ADD CONSTRAINT fk_rails_99dc12d4fd FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: entries fk_rails_cd311de9ac; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY entries
    ADD CONSTRAINT fk_rails_cd311de9ac FOREIGN KEY (pool_id) REFERENCES pools(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20170128224320');

INSERT INTO schema_migrations (version) VALUES ('20170128235805');

INSERT INTO schema_migrations (version) VALUES ('20170129011235');

INSERT INTO schema_migrations (version) VALUES ('20170129011526');

INSERT INTO schema_migrations (version) VALUES ('20170129013216');

INSERT INTO schema_migrations (version) VALUES ('20170129014809');

INSERT INTO schema_migrations (version) VALUES ('20170129030402');

INSERT INTO schema_migrations (version) VALUES ('20170129030413');

INSERT INTO schema_migrations (version) VALUES ('20170129034734');

INSERT INTO schema_migrations (version) VALUES ('20170130035728');

INSERT INTO schema_migrations (version) VALUES ('20170211202227');

INSERT INTO schema_migrations (version) VALUES ('20170211202408');

INSERT INTO schema_migrations (version) VALUES ('20170211202420');

INSERT INTO schema_migrations (version) VALUES ('20170211202426');

INSERT INTO schema_migrations (version) VALUES ('20170211202432');

INSERT INTO schema_migrations (version) VALUES ('20170211202441');

INSERT INTO schema_migrations (version) VALUES ('20170211202645');

INSERT INTO schema_migrations (version) VALUES ('20170218051550');

INSERT INTO schema_migrations (version) VALUES ('20170226010635');

