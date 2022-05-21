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
    key character varying(255) NOT NULL,
    value character varying(255) DEFAULT NULL::character varying,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: attendances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attendances (
    id bigint NOT NULL,
    event_id bigint NOT NULL,
    user_id bigint NOT NULL,
    registration_group_id bigint,
    registration_date timestamp with time zone,
    status bigint,
    email_sent boolean DEFAULT false,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    organization character varying(255) DEFAULT NULL::character varying,
    country character varying(255) DEFAULT NULL::character varying,
    state character varying(255) DEFAULT NULL::character varying,
    city character varying(255) DEFAULT NULL::character varying,
    badge_name character varying(255) DEFAULT NULL::character varying,
    notes character varying(255) DEFAULT NULL::character varying,
    event_price numeric(10,0) DEFAULT NULL::numeric,
    registration_quota_id bigint,
    registration_value numeric(10,0) DEFAULT NULL::numeric,
    registration_period_id bigint,
    advised boolean DEFAULT false,
    advised_at timestamp with time zone,
    organization_size integer DEFAULT 0,
    years_of_experience integer DEFAULT 0,
    experience_in_agility integer DEFAULT 0,
    education_level integer DEFAULT 0,
    queue_time bigint,
    last_status_change_date timestamp with time zone,
    job_role bigint DEFAULT '0'::bigint,
    due_date timestamp with time zone,
    payment_type bigint,
    registered_by_id bigint NOT NULL,
    other_job_role character varying,
    source_of_interest integer DEFAULT 0 NOT NULL,
    welcome_email_sent boolean DEFAULT false,
    lock_version integer
);


--
-- Name: attendances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attendances_id_seq
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
    id bigint NOT NULL,
    user_id bigint,
    provider character varying(255) DEFAULT NULL::character varying,
    uid character varying(255) DEFAULT NULL::character varying,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    refresh_token character varying(255) DEFAULT NULL::character varying
);


--
-- Name: authentications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.authentications_id_seq
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
    id bigint NOT NULL,
    name character varying(255) DEFAULT NULL::character varying,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    attendance_limit bigint,
    full_price numeric(10,0) DEFAULT NULL::numeric,
    start_date timestamp with time zone,
    end_date timestamp with time zone,
    link character varying(255) DEFAULT NULL::character varying,
    days_to_charge bigint DEFAULT '7'::bigint,
    main_email_contact character varying(255) NOT NULL,
    event_image character varying(255) DEFAULT NULL::character varying,
    country character varying(255) NOT NULL,
    state character varying(255) NOT NULL,
    city character varying(255) NOT NULL,
    event_nickname character varying,
    event_schedule_link character varying,
    event_remote_manual_link character varying,
    event_remote_platform_name character varying,
    event_remote_platform_mail character varying,
    event_remote boolean DEFAULT false,
    privacy_policy character varying
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.events_id_seq
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
    event_id bigint,
    user_id bigint
);


--
-- Name: invoices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invoices (
    id bigint NOT NULL,
    transaction_id character varying(255) DEFAULT NULL::character varying NOT NULL,
    payer_email character varying(255) DEFAULT NULL::character varying,
    settle_amount numeric(10,0) DEFAULT NULL::numeric NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    attendance_id bigint,
    invoice_date timestamp without time zone NOT NULL,
    payment_type integer DEFAULT 0 NOT NULL,
    status integer DEFAULT 1
);


--
-- Name: invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.invoices_id_seq OWNED BY public.invoices.id;


--
-- Name: registration_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.registration_groups (
    id bigint NOT NULL,
    event_id bigint,
    name character varying(255) DEFAULT NULL::character varying,
    capacity bigint,
    discount bigint,
    token character varying(255) DEFAULT NULL::character varying,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    leader_id bigint,
    minimum_size bigint,
    amount numeric(10,0) DEFAULT NULL::numeric,
    automatic_approval boolean DEFAULT false,
    registration_quota_id bigint,
    paid_in_advance boolean DEFAULT false
);


--
-- Name: registration_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.registration_groups_id_seq
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
    id bigint NOT NULL,
    event_id bigint,
    title character varying(255) DEFAULT NULL::character varying,
    start_at timestamp with time zone,
    end_at timestamp with time zone,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    price numeric(10,0) NOT NULL
);


--
-- Name: registration_periods_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.registration_periods_id_seq
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
    id bigint NOT NULL,
    quota bigint,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    event_id bigint,
    registration_price_id bigint,
    "order" bigint,
    closed boolean DEFAULT false,
    price numeric(10,0) NOT NULL
);


--
-- Name: registration_quotas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.registration_quotas_id_seq
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
    version character varying(255) NOT NULL
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
    id bigint NOT NULL,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    country character varying(255) DEFAULT NULL::character varying,
    state character varying(255) DEFAULT NULL::character varying,
    city character varying(255) DEFAULT NULL::character varying,
    gender integer DEFAULT 5,
    roles_mask bigint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    registration_group_id bigint,
    role bigint DEFAULT '0'::bigint NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255) DEFAULT NULL::character varying,
    reset_password_sent_at timestamp with time zone,
    remember_created_at timestamp with time zone,
    sign_in_count bigint DEFAULT '0'::bigint NOT NULL,
    current_sign_in_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    current_sign_in_ip character varying(255) DEFAULT NULL::character varying,
    last_sign_in_ip character varying(255) DEFAULT NULL::character varying,
    confirmation_token character varying(255) DEFAULT NULL::character varying,
    confirmed_at timestamp with time zone,
    confirmation_sent_at timestamp with time zone,
    unconfirmed_email character varying(255) DEFAULT NULL::character varying,
    failed_attempts bigint DEFAULT '0'::bigint NOT NULL,
    unlock_token character varying(255) DEFAULT NULL::character varying,
    locked_at timestamp with time zone,
    user_image character varying(255) DEFAULT NULL::character varying,
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
-- Name: invoices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices ALTER COLUMN id SET DEFAULT nextval('public.invoices_id_seq'::regclass);


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
-- Name: ar_internal_metadata idx_4539773_primary; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT idx_4539773_primary PRIMARY KEY (key);


--
-- Name: attendances idx_4539782_primary; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendances
    ADD CONSTRAINT idx_4539782_primary PRIMARY KEY (id);


--
-- Name: authentications idx_4539813_primary; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authentications
    ADD CONSTRAINT idx_4539813_primary PRIMARY KEY (id);


--
-- Name: events idx_4539825_primary; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT idx_4539825_primary PRIMARY KEY (id);


--
-- Name: invoices idx_4539845_primary; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT idx_4539845_primary PRIMARY KEY (id);


--
-- Name: registration_groups idx_4539859_primary; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration_groups
    ADD CONSTRAINT idx_4539859_primary PRIMARY KEY (id);


--
-- Name: registration_periods idx_4539873_primary; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration_periods
    ADD CONSTRAINT idx_4539873_primary PRIMARY KEY (id);


--
-- Name: registration_quotas idx_4539880_primary; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration_quotas
    ADD CONSTRAINT idx_4539880_primary PRIMARY KEY (id);


--
-- Name: users idx_4539890_primary; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT idx_4539890_primary PRIMARY KEY (id);


--
-- Name: slack_configurations slack_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slack_configurations
    ADD CONSTRAINT slack_configurations_pkey PRIMARY KEY (id);


--
-- Name: idx_4539782_fk_rails_4eb9f97929; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_4539782_fk_rails_4eb9f97929 ON public.attendances USING btree (registered_by_id);


--
-- Name: idx_4539782_fk_rails_a2b9ca8d82; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_4539782_fk_rails_a2b9ca8d82 ON public.attendances USING btree (registration_period_id);


--
-- Name: idx_4539782_index_attendances_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_4539782_index_attendances_on_event_id ON public.attendances USING btree (event_id);


--
-- Name: idx_4539782_index_attendances_on_registration_quota_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_4539782_index_attendances_on_registration_quota_id ON public.attendances USING btree (registration_quota_id);


--
-- Name: idx_4539782_index_attendances_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_4539782_index_attendances_on_user_id ON public.attendances USING btree (user_id);


--
-- Name: idx_4539840_index_events_users_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_4539840_index_events_users_on_event_id ON public.events_users USING btree (event_id);


--
-- Name: idx_4539840_index_events_users_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_4539840_index_events_users_on_user_id ON public.events_users USING btree (user_id);


--
-- Name: idx_4539845_index_payment_notifications_on_attendance_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_4539845_index_payment_notifications_on_attendance_id ON public.invoices USING btree (attendance_id);


--
-- Name: idx_4539885_unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_4539885_unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: idx_4539890_fk_rails_ebe9fba698; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_4539890_fk_rails_ebe9fba698 ON public.users USING btree (registration_group_id);


--
-- Name: idx_4539890_index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_4539890_index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: idx_4539890_index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_4539890_index_users_on_email ON public.users USING btree (email);


--
-- Name: idx_4539890_index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_4539890_index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: idx_4539890_index_users_on_unlock_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_4539890_index_users_on_unlock_token ON public.users USING btree (unlock_token);


--
-- Name: index_attendances_on_education_level; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attendances_on_education_level ON public.attendances USING btree (education_level);


--
-- Name: index_attendances_on_source_of_interest; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attendances_on_source_of_interest ON public.attendances USING btree (source_of_interest);


--
-- Name: index_attendances_on_years_of_experience; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attendances_on_years_of_experience ON public.attendances USING btree (years_of_experience);


--
-- Name: index_invoices_on_payment_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_invoices_on_payment_type ON public.invoices USING btree (payment_type);


--
-- Name: index_invoices_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_invoices_on_status ON public.invoices USING btree (status);


--
-- Name: index_slack_configurations_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_slack_configurations_on_event_id ON public.slack_configurations USING btree (event_id);


--
-- Name: index_users_on_disability; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_disability ON public.users USING btree (disability);


--
-- Name: index_users_on_education_level; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_education_level ON public.users USING btree (education_level);


--
-- Name: index_users_on_ethnicity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_ethnicity ON public.users USING btree (ethnicity);


--
-- Name: index_users_on_gender; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_gender ON public.users USING btree (gender);


--
-- Name: invoices_pkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invoices_pkey ON public.invoices USING btree (id);


--
-- Name: attendances fk_rails_23280a60c9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendances
    ADD CONSTRAINT fk_rails_23280a60c9 FOREIGN KEY (registration_quota_id) REFERENCES public.registration_quotas(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: invoices fk_rails_2e64051bbf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT fk_rails_2e64051bbf FOREIGN KEY (attendance_id) REFERENCES public.attendances(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: attendances fk_rails_4eb9f97929; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendances
    ADD CONSTRAINT fk_rails_4eb9f97929 FOREIGN KEY (registered_by_id) REFERENCES public.users(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: attendances fk_rails_777eb7170a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendances
    ADD CONSTRAINT fk_rails_777eb7170a FOREIGN KEY (event_id) REFERENCES public.events(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: attendances fk_rails_77ad02f5c5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendances
    ADD CONSTRAINT fk_rails_77ad02f5c5 FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: slack_configurations fk_rails_9dbb8d5cb7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slack_configurations
    ADD CONSTRAINT fk_rails_9dbb8d5cb7 FOREIGN KEY (event_id) REFERENCES public.events(id);


--
-- Name: attendances fk_rails_a2b9ca8d82; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendances
    ADD CONSTRAINT fk_rails_a2b9ca8d82 FOREIGN KEY (registration_period_id) REFERENCES public.registration_periods(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: users fk_rails_ebe9fba698; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_ebe9fba698 FOREIGN KEY (registration_group_id) REFERENCES public.registration_groups(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


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
('20211001162719'),
('20220511192202'),
('20220520164832'),
('20220520213716');


