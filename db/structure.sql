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
-- Name: attendances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attendances (
    id integer NOT NULL,
    event_id integer NOT NULL,
    user_id integer NOT NULL,
    registration_group_id integer,
    registration_date timestamp without time zone,
    email_sent boolean DEFAULT false,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    organization character varying,
    country character varying,
    state character varying,
    city character varying,
    badge_name character varying,
    notes character varying,
    event_price numeric,
    registration_quota_id integer,
    registration_value numeric(10,0),
    registration_period_id integer,
    advised boolean DEFAULT false,
    advised_at timestamp without time zone,
    organization_size integer DEFAULT 0,
    years_of_experience integer DEFAULT 0,
    experience_in_agility integer DEFAULT 0,
    education_level integer DEFAULT 0,
    queue_time integer,
    last_status_change_date timestamp without time zone,
    job_role integer DEFAULT 0,
    due_date timestamp without time zone,
    status integer,
    payment_type integer,
    registered_by_id integer NOT NULL,
    other_job_role character varying,
    source_of_interest integer DEFAULT 0 NOT NULL,
    welcome_email_sent boolean DEFAULT false,
    lock_version integer
);


--
-- Name: attendances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attendances_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attendances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.attendances_id_seq OWNED BY public.attendances.id;


--
-- Name: authentications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.authentications (
    id integer NOT NULL,
    user_id integer,
    provider character varying,
    uid character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    refresh_token character varying
);


--
-- Name: authentications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.authentications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authentications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.authentications_id_seq OWNED BY public.authentications.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    attendance_limit integer,
    full_price numeric,
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    link character varying,
    days_to_charge integer DEFAULT 7,
    main_email_contact character varying DEFAULT ''::character varying NOT NULL,
    event_image character varying,
    country character varying NOT NULL,
    state character varying NOT NULL,
    city character varying NOT NULL,
    event_nickname character varying,
    event_schedule_link character varying,
    event_remote_manual_link character varying,
    event_remote_platform_name character varying,
    event_remote_platform_mail character varying,
    event_remote boolean DEFAULT false
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: events_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events_users (
    event_id integer,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: payment_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_notifications (
    id integer NOT NULL,
    params text,
    status character varying,
    transaction_id character varying,
    payer_email character varying,
    settle_amount numeric,
    settle_currency character varying,
    notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    attendance_id integer
);


--
-- Name: payment_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payment_notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payment_notifications_id_seq OWNED BY public.payment_notifications.id;


--
-- Name: registration_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.registration_groups (
    id integer NOT NULL,
    event_id integer,
    name character varying,
    capacity integer,
    discount integer,
    token character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    leader_id integer,
    minimum_size integer,
    amount numeric,
    automatic_approval boolean DEFAULT false,
    registration_quota_id integer,
    paid_in_advance boolean DEFAULT false
);


--
-- Name: registration_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.registration_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: registration_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.registration_groups_id_seq OWNED BY public.registration_groups.id;


--
-- Name: registration_periods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.registration_periods (
    id integer NOT NULL,
    event_id integer,
    title character varying,
    start_at timestamp without time zone,
    end_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    price numeric NOT NULL
);


--
-- Name: registration_periods_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.registration_periods_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: registration_periods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.registration_periods_id_seq OWNED BY public.registration_periods.id;


--
-- Name: registration_quotas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.registration_quotas (
    id integer NOT NULL,
    quota integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    event_id integer,
    registration_price_id integer,
    "order" integer,
    closed boolean DEFAULT false,
    price numeric NOT NULL
);


--
-- Name: registration_quotas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.registration_quotas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: registration_quotas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.registration_quotas_id_seq OWNED BY public.registration_quotas.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: slack_configurations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.slack_configurations (
    id bigint NOT NULL,
    event_id integer NOT NULL,
    room_webhook character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: slack_configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.slack_configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: slack_configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.slack_configurations_id_seq OWNED BY public.slack_configurations.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    email character varying NOT NULL,
    country character varying,
    state character varying,
    city character varying,
    gender integer DEFAULT 5,
    roles_mask integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    registration_group_id integer,
    role integer DEFAULT 0 NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    failed_attempts integer DEFAULT 0 NOT NULL,
    unlock_token character varying,
    locked_at timestamp without time zone,
    user_image character varying,
    birth_date date,
    education_level integer DEFAULT 0,
    school character varying,
    ethnicity integer DEFAULT 0 NOT NULL,
    disability integer DEFAULT 5 NOT NULL
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
-- Name: attendances id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendances ALTER COLUMN id SET DEFAULT nextval('public.attendances_id_seq'::regclass);


--
-- Name: authentications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authentications ALTER COLUMN id SET DEFAULT nextval('public.authentications_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: payment_notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_notifications ALTER COLUMN id SET DEFAULT nextval('public.payment_notifications_id_seq'::regclass);


--
-- Name: registration_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration_groups ALTER COLUMN id SET DEFAULT nextval('public.registration_groups_id_seq'::regclass);


--
-- Name: registration_periods id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration_periods ALTER COLUMN id SET DEFAULT nextval('public.registration_periods_id_seq'::regclass);


--
-- Name: registration_quotas id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration_quotas ALTER COLUMN id SET DEFAULT nextval('public.registration_quotas_id_seq'::regclass);


--
-- Name: slack_configurations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slack_configurations ALTER COLUMN id SET DEFAULT nextval('public.slack_configurations_id_seq'::regclass);


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
-- Name: attendances attendances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendances
    ADD CONSTRAINT attendances_pkey PRIMARY KEY (id);


--
-- Name: authentications authentications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authentications
    ADD CONSTRAINT authentications_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: payment_notifications payment_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_notifications
    ADD CONSTRAINT payment_notifications_pkey PRIMARY KEY (id);


--
-- Name: registration_groups registration_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration_groups
    ADD CONSTRAINT registration_groups_pkey PRIMARY KEY (id);


--
-- Name: registration_periods registration_periods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration_periods
    ADD CONSTRAINT registration_periods_pkey PRIMARY KEY (id);


--
-- Name: registration_quotas registration_quotas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration_quotas
    ADD CONSTRAINT registration_quotas_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: slack_configurations slack_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slack_configurations
    ADD CONSTRAINT slack_configurations_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_attendances_on_education_level; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attendances_on_education_level ON public.attendances USING btree (education_level);


--
-- Name: index_attendances_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attendances_on_event_id ON public.attendances USING btree (event_id);


--
-- Name: index_attendances_on_registered_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attendances_on_registered_by_id ON public.attendances USING btree (registered_by_id);


--
-- Name: index_attendances_on_registration_quota_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attendances_on_registration_quota_id ON public.attendances USING btree (registration_quota_id);


--
-- Name: index_attendances_on_source_of_interest; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attendances_on_source_of_interest ON public.attendances USING btree (source_of_interest);


--
-- Name: index_attendances_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attendances_on_user_id ON public.attendances USING btree (user_id);


--
-- Name: index_attendances_on_years_of_experience; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attendances_on_years_of_experience ON public.attendances USING btree (years_of_experience);


--
-- Name: index_events_users_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_users_on_event_id ON public.events_users USING btree (event_id);


--
-- Name: index_events_users_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_users_on_user_id ON public.events_users USING btree (user_id);


--
-- Name: index_payment_notifications_on_attendance_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payment_notifications_on_attendance_id ON public.payment_notifications USING btree (attendance_id);


--
-- Name: index_slack_configurations_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_slack_configurations_on_event_id ON public.slack_configurations USING btree (event_id);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: index_users_on_disability; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_disability ON public.users USING btree (disability);


--
-- Name: index_users_on_education_level; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_education_level ON public.users USING btree (education_level);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_ethnicity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_ethnicity ON public.users USING btree (ethnicity);


--
-- Name: index_users_on_gender; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_gender ON public.users USING btree (gender);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_unlock_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_unlock_token ON public.users USING btree (unlock_token);


--
-- Name: attendances fk_rails_23280a60c9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendances
    ADD CONSTRAINT fk_rails_23280a60c9 FOREIGN KEY (registration_quota_id) REFERENCES public.registration_quotas(id);


--
-- Name: payment_notifications fk_rails_2e64051bbf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_notifications
    ADD CONSTRAINT fk_rails_2e64051bbf FOREIGN KEY (attendance_id) REFERENCES public.attendances(id);


--
-- Name: attendances fk_rails_4eb9f97929; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendances
    ADD CONSTRAINT fk_rails_4eb9f97929 FOREIGN KEY (registered_by_id) REFERENCES public.users(id);


--
-- Name: attendances fk_rails_777eb7170a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendances
    ADD CONSTRAINT fk_rails_777eb7170a FOREIGN KEY (event_id) REFERENCES public.events(id);


--
-- Name: attendances fk_rails_77ad02f5c5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendances
    ADD CONSTRAINT fk_rails_77ad02f5c5 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: slack_configurations fk_rails_9dbb8d5cb7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slack_configurations
    ADD CONSTRAINT fk_rails_9dbb8d5cb7 FOREIGN KEY (event_id) REFERENCES public.events(id);


--
-- Name: attendances fk_rails_a2b9ca8d82; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendances
    ADD CONSTRAINT fk_rails_a2b9ca8d82 FOREIGN KEY (registration_period_id) REFERENCES public.registration_periods(id);


--
-- Name: users fk_rails_ebe9fba698; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_ebe9fba698 FOREIGN KEY (registration_group_id) REFERENCES public.registration_groups(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20121217222354'),
('20121229190700'),
('20130318014329'),
('20130325050103'),
('20130328055205'),
('20130416035732'),
('20130418000441'),
('20130418061005'),
('20130507030313'),
('20130620204230'),
('20150322025042'),
('20150329160512'),
('20150407174951'),
('20150407180214'),
('20150412044311'),
('20150412220559'),
('20150419035312'),
('20150419042606'),
('20150419045312'),
('20150419052050'),
('20150421220159'),
('20150424001453'),
('20150502205655'),
('20150503001731'),
('20150503072125'),
('20150503212201'),
('20150507201703'),
('20150606203438'),
('20150616193824'),
('20150628062128'),
('20151005170325'),
('20151231024432'),
('20151231050931'),
('20160103200312'),
('20160104003728'),
('20160119003402'),
('20160127030848'),
('20160215142848'),
('20160217002804'),
('20160221011615'),
('20160221154305'),
('20160302151710'),
('20160303004112'),
('20160618142016'),
('20170311160016'),
('20170425042251'),
('20170507021846'),
('20180502154501'),
('20180521195234'),
('20180602214422'),
('20180930220853'),
('20190103134846'),
('20210606223020'),
('20210609132902'),
('20210726201638'),
('20210930193404'),
('20211001162719');


