SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: award_ceremonies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.award_ceremonies (
    id integer NOT NULL,
    name text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    locks_at timestamp without time zone
);


--
-- Name: award_ceremonies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.award_ceremonies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: award_ceremonies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.award_ceremonies_id_seq OWNED BY public.award_ceremonies.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    name text,
    award_ceremony_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entries (
    id integer NOT NULL,
    pool_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.entries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.entries_id_seq OWNED BY public.entries.id;


--
-- Name: nominees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nominees (
    id integer NOT NULL,
    name text,
    category_id integer,
    winner boolean
);


--
-- Name: nominees_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.nominees_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nominees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.nominees_id_seq OWNED BY public.nominees.id;


--
-- Name: picks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.picks (
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

CREATE SEQUENCE public.picks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: picks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.picks_id_seq OWNED BY public.picks.id;


--
-- Name: pools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pools (
    id integer NOT NULL,
    award_ceremony_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: pools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pools_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pools_id_seq OWNED BY public.pools.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
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

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: award_ceremonies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.award_ceremonies ALTER COLUMN id SET DEFAULT nextval('public.award_ceremonies_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entries ALTER COLUMN id SET DEFAULT nextval('public.entries_id_seq'::regclass);


--
-- Name: nominees id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nominees ALTER COLUMN id SET DEFAULT nextval('public.nominees_id_seq'::regclass);


--
-- Name: picks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.picks ALTER COLUMN id SET DEFAULT nextval('public.picks_id_seq'::regclass);


--
-- Name: pools id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pools ALTER COLUMN id SET DEFAULT nextval('public.pools_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: award_ceremonies award_ceremonies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.award_ceremonies
    ADD CONSTRAINT award_ceremonies_pkey PRIMARY KEY (id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: entries entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entries
    ADD CONSTRAINT entries_pkey PRIMARY KEY (id);


--
-- Name: nominees nominees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nominees
    ADD CONSTRAINT nominees_pkey PRIMARY KEY (id);


--
-- Name: picks picks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.picks
    ADD CONSTRAINT picks_pkey PRIMARY KEY (id);


--
-- Name: pools pools_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pools
    ADD CONSTRAINT pools_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_categories_on_award_ceremony_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_on_award_ceremony_id ON public.categories USING btree (award_ceremony_id);


--
-- Name: index_entries_on_pool_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entries_on_pool_id ON public.entries USING btree (pool_id);


--
-- Name: index_entries_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entries_on_user_id ON public.entries USING btree (user_id);


--
-- Name: index_entries_on_user_id_and_pool_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_entries_on_user_id_and_pool_id ON public.entries USING btree (user_id, pool_id);


--
-- Name: index_nominees_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_nominees_on_category_id ON public.nominees USING btree (category_id);


--
-- Name: index_picks_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_picks_on_category_id ON public.picks USING btree (category_id);


--
-- Name: index_picks_on_entry_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_picks_on_entry_id ON public.picks USING btree (entry_id);


--
-- Name: index_picks_on_entry_id_and_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_picks_on_entry_id_and_category_id ON public.picks USING btree (entry_id, category_id);


--
-- Name: index_picks_on_nominee_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_picks_on_nominee_id ON public.picks USING btree (nominee_id);


--
-- Name: index_pools_on_award_ceremony_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pools_on_award_ceremony_id ON public.pools USING btree (award_ceremony_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: nominees fk_rails_3295d19bd4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nominees
    ADD CONSTRAINT fk_rails_3295d19bd4 FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- Name: picks fk_rails_42358aa0a9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.picks
    ADD CONSTRAINT fk_rails_42358aa0a9 FOREIGN KEY (entry_id) REFERENCES public.entries(id);


--
-- Name: categories fk_rails_53b715888d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT fk_rails_53b715888d FOREIGN KEY (award_ceremony_id) REFERENCES public.award_ceremonies(id);


--
-- Name: picks fk_rails_78f64222e2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.picks
    ADD CONSTRAINT fk_rails_78f64222e2 FOREIGN KEY (nominee_id) REFERENCES public.nominees(id);


--
-- Name: pools fk_rails_7dd1327a40; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pools
    ADD CONSTRAINT fk_rails_7dd1327a40 FOREIGN KEY (award_ceremony_id) REFERENCES public.award_ceremonies(id);


--
-- Name: entries fk_rails_99dc12d4fd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entries
    ADD CONSTRAINT fk_rails_99dc12d4fd FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: entries fk_rails_cd311de9ac; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entries
    ADD CONSTRAINT fk_rails_cd311de9ac FOREIGN KEY (pool_id) REFERENCES public.pools(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20261115163643'),
('20261115163552'),
('20170226010635'),
('20170218051550'),
('20170211202645'),
('20170211202441'),
('20170211202432'),
('20170211202426'),
('20170211202420'),
('20170211202408'),
('20170211202227'),
('20170130035728'),
('20170129034734'),
('20170129030413'),
('20170129030402'),
('20170129014809'),
('20170129013216'),
('20170129011526'),
('20170129011235'),
('20170128235805'),
('20170128224320');

