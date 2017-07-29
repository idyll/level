--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 9.6.3

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

--
-- Name: invitation_state; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE invitation_state AS ENUM (
    'PENDING',
    'ACCEPTED',
    'REVOKED'
);


--
-- Name: message_state; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE message_state AS ENUM (
    'DRAFT',
    'SENT',
    'DELETED'
);


--
-- Name: team_state; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE team_state AS ENUM (
    'ACTIVE',
    'DISABLED'
);


--
-- Name: thread_state; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE thread_state AS ENUM (
    'SENT',
    'DELETED'
);


--
-- Name: user_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE user_role AS ENUM (
    'OWNER',
    'ADMIN',
    'MEMBER'
);


--
-- Name: user_state; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE user_state AS ENUM (
    'ACTIVE',
    'DISABLED'
);


--
-- Name: next_global_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION next_global_id(OUT result bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
    our_epoch bigint := 1501268767000;
    seq_id bigint;
    now_millis bigint;
    shard_id int := 1;
BEGIN
    SELECT nextval('global_id_seq') % 1024 INTO seq_id;

    SELECT FLOOR(EXTRACT(EPOCH FROM clock_timestamp()) * 1000) INTO now_millis;
    result := (now_millis - our_epoch) << 23;
    result := result | (shard_id << 10);
    result := result | (seq_id);
END;
$$;


--
-- Name: global_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE global_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: invitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE invitations (
    id bigint DEFAULT next_global_id() NOT NULL,
    team_id bigint NOT NULL,
    invitor_id bigint NOT NULL,
    acceptor_id bigint,
    state invitation_state DEFAULT 'PENDING'::invitation_state NOT NULL,
    role user_role DEFAULT 'MEMBER'::user_role NOT NULL,
    email character varying(255) NOT NULL,
    token uuid NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE messages (
    id bigint DEFAULT next_global_id() NOT NULL,
    team_id bigint NOT NULL,
    user_id bigint NOT NULL,
    thread_id bigint NOT NULL,
    state message_state DEFAULT 'DRAFT'::message_state NOT NULL,
    body text NOT NULL,
    is_truncated boolean DEFAULT false NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp without time zone
);


--
-- Name: teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE teams (
    id bigint DEFAULT next_global_id() NOT NULL,
    name character varying(255) NOT NULL,
    slug character varying(63) NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    state team_state DEFAULT 'ACTIVE'::team_state NOT NULL
);


--
-- Name: threads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE threads (
    id bigint DEFAULT next_global_id() NOT NULL,
    team_id bigint NOT NULL,
    creator_id bigint NOT NULL,
    state thread_state DEFAULT 'SENT'::thread_state NOT NULL,
    subject character varying(255) NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id bigint DEFAULT next_global_id() NOT NULL,
    team_id bigint NOT NULL,
    email character varying(255) NOT NULL,
    username character varying(20) NOT NULL,
    first_name character varying(255),
    last_name character varying(255),
    time_zone character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    role user_role DEFAULT 'MEMBER'::user_role NOT NULL,
    state user_state DEFAULT 'ACTIVE'::user_state NOT NULL
);


--
-- Name: invitations invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY invitations
    ADD CONSTRAINT invitations_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: threads threads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY threads
    ADD CONSTRAINT threads_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: invitations_invitor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invitations_invitor_id_index ON invitations USING btree (invitor_id);


--
-- Name: invitations_team_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invitations_team_id_index ON invitations USING btree (team_id);


--
-- Name: invitations_token_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX invitations_token_index ON invitations USING btree (token);


--
-- Name: invitations_unique_pending_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX invitations_unique_pending_email ON invitations USING btree (lower((email)::text)) WHERE (state = 'PENDING'::invitation_state);


--
-- Name: messages_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX messages_id_index ON messages USING btree (id);


--
-- Name: messages_thread_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX messages_thread_id_index ON messages USING btree (thread_id);


--
-- Name: teams_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX teams_slug_index ON teams USING btree (slug);


--
-- Name: threads_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX threads_id_index ON threads USING btree (id);


--
-- Name: threads_team_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX threads_team_id_index ON threads USING btree (team_id);


--
-- Name: users_team_id_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_team_id_email_index ON users USING btree (team_id, email);


--
-- Name: users_team_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_team_id_index ON users USING btree (team_id);


--
-- Name: users_team_id_username_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_team_id_username_index ON users USING btree (team_id, username);


--
-- Name: invitations invitations_acceptor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY invitations
    ADD CONSTRAINT invitations_acceptor_id_fkey FOREIGN KEY (acceptor_id) REFERENCES users(id);


--
-- Name: invitations invitations_invitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY invitations
    ADD CONSTRAINT invitations_invitor_id_fkey FOREIGN KEY (invitor_id) REFERENCES users(id);


--
-- Name: invitations invitations_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY invitations
    ADD CONSTRAINT invitations_team_id_fkey FOREIGN KEY (team_id) REFERENCES teams(id);


--
-- Name: messages messages_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_team_id_fkey FOREIGN KEY (team_id) REFERENCES teams(id);


--
-- Name: messages messages_thread_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES threads(id);


--
-- Name: messages messages_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: threads threads_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY threads
    ADD CONSTRAINT threads_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES users(id);


--
-- Name: threads threads_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY threads
    ADD CONSTRAINT threads_team_id_fkey FOREIGN KEY (team_id) REFERENCES teams(id);


--
-- Name: users users_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_team_id_fkey FOREIGN KEY (team_id) REFERENCES teams(id);


--
-- PostgreSQL database dump complete
--

INSERT INTO "schema_migrations" (version) VALUES (20170527220454), (20170528000152), (20170715050656), (20170723211950), (20170723212331), (20170724045329), (20170727231335), (20170729023453), (20170729045310), (20170813212405);

