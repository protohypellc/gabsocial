--
-- PostgreSQL database dump
--

-- Dumped from database version 10.10 (Ubuntu 10.10-0ubuntu0.18.04.1)
-- Dumped by pg_dump version 10.10 (Ubuntu 10.10-0ubuntu0.18.04.1)

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

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: timestamp_id(text); Type: FUNCTION; Schema: public; Owner: root
--

CREATE FUNCTION public.timestamp_id(table_name text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
  DECLARE
    time_part bigint;
    sequence_base bigint;
    tail bigint;
  BEGIN
    time_part := (
      -- Get the time in milliseconds
      ((date_part('epoch', now()) * 1000))::bigint
      -- And shift it over two bytes
      << 16);

    sequence_base := (
      'x' ||
      -- Take the first two bytes (four hex characters)
      substr(
        -- Of the MD5 hash of the data we documented
        md5(table_name ||
          'ff15603e7acfe8c35999d972418ef180' ||
          time_part::text
        ),
        1, 4
      )
    -- And turn it into a bigint
    )::bit(16)::bigint;

    -- Finally, add our sequence number to our base, and chop
    -- it to the last two bytes
    tail := (
      (sequence_base + nextval(table_name || '_id_seq'))
      & 65535);

    -- Return the time part and the sequence part. OR appears
    -- faster here than addition, but they're equivalent:
    -- time_part has no trailing two bytes, and tail is only
    -- the last two bytes.
    RETURN time_part | tail;
  END
$$;


ALTER FUNCTION public.timestamp_id(table_name text) OWNER TO root;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: account_conversations; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.account_conversations (
    id bigint NOT NULL,
    account_id bigint,
    conversation_id bigint,
    participant_account_ids bigint[] DEFAULT '{}'::bigint[] NOT NULL,
    status_ids bigint[] DEFAULT '{}'::bigint[] NOT NULL,
    last_status_id bigint,
    lock_version integer DEFAULT 0 NOT NULL,
    unread boolean DEFAULT false NOT NULL
);


ALTER TABLE public.account_conversations OWNER TO root;

--
-- Name: account_conversations_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.account_conversations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_conversations_id_seq OWNER TO root;

--
-- Name: account_conversations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.account_conversations_id_seq OWNED BY public.account_conversations.id;


--
-- Name: account_domain_blocks; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.account_domain_blocks (
    domain character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_id bigint,
    id bigint NOT NULL
);


ALTER TABLE public.account_domain_blocks OWNER TO root;

--
-- Name: account_domain_blocks_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.account_domain_blocks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_domain_blocks_id_seq OWNER TO root;

--
-- Name: account_domain_blocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.account_domain_blocks_id_seq OWNED BY public.account_domain_blocks.id;


--
-- Name: account_identity_proofs; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.account_identity_proofs (
    id bigint NOT NULL,
    account_id bigint,
    provider character varying DEFAULT ''::character varying NOT NULL,
    provider_username character varying DEFAULT ''::character varying NOT NULL,
    token text DEFAULT ''::text NOT NULL,
    verified boolean DEFAULT false NOT NULL,
    live boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.account_identity_proofs OWNER TO root;

--
-- Name: account_identity_proofs_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.account_identity_proofs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_identity_proofs_id_seq OWNER TO root;

--
-- Name: account_identity_proofs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.account_identity_proofs_id_seq OWNED BY public.account_identity_proofs.id;


--
-- Name: account_moderation_notes; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.account_moderation_notes (
    id bigint NOT NULL,
    content text NOT NULL,
    account_id bigint NOT NULL,
    target_account_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.account_moderation_notes OWNER TO root;

--
-- Name: account_moderation_notes_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.account_moderation_notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_moderation_notes_id_seq OWNER TO root;

--
-- Name: account_moderation_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.account_moderation_notes_id_seq OWNED BY public.account_moderation_notes.id;


--
-- Name: account_pins; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.account_pins (
    id bigint NOT NULL,
    account_id bigint,
    target_account_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.account_pins OWNER TO root;

--
-- Name: account_pins_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.account_pins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_pins_id_seq OWNER TO root;

--
-- Name: account_pins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.account_pins_id_seq OWNED BY public.account_pins.id;


--
-- Name: account_stats; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.account_stats (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    statuses_count bigint DEFAULT 0 NOT NULL,
    following_count bigint DEFAULT 0 NOT NULL,
    followers_count bigint DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    last_status_at timestamp without time zone
);


ALTER TABLE public.account_stats OWNER TO root;

--
-- Name: account_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.account_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_stats_id_seq OWNER TO root;

--
-- Name: account_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.account_stats_id_seq OWNED BY public.account_stats.id;


--
-- Name: account_tag_stats; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.account_tag_stats (
    id bigint NOT NULL,
    tag_id bigint NOT NULL,
    accounts_count bigint DEFAULT 0 NOT NULL,
    hidden boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.account_tag_stats OWNER TO root;

--
-- Name: account_tag_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.account_tag_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_tag_stats_id_seq OWNER TO root;

--
-- Name: account_tag_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.account_tag_stats_id_seq OWNED BY public.account_tag_stats.id;


--
-- Name: account_verification_requests; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.account_verification_requests (
    id bigint NOT NULL,
    account_id bigint,
    image_file_name character varying,
    image_content_type character varying,
    image_file_size integer,
    image_updated_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.account_verification_requests OWNER TO root;

--
-- Name: account_verification_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.account_verification_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_verification_requests_id_seq OWNER TO root;

--
-- Name: account_verification_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.account_verification_requests_id_seq OWNED BY public.account_verification_requests.id;


--
-- Name: account_warning_presets; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.account_warning_presets (
    id bigint NOT NULL,
    text text DEFAULT ''::text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.account_warning_presets OWNER TO root;

--
-- Name: account_warning_presets_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.account_warning_presets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_warning_presets_id_seq OWNER TO root;

--
-- Name: account_warning_presets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.account_warning_presets_id_seq OWNED BY public.account_warning_presets.id;


--
-- Name: account_warnings; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.account_warnings (
    id bigint NOT NULL,
    account_id bigint,
    target_account_id bigint,
    action integer DEFAULT 0 NOT NULL,
    text text DEFAULT ''::text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.account_warnings OWNER TO root;

--
-- Name: account_warnings_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.account_warnings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_warnings_id_seq OWNER TO root;

--
-- Name: account_warnings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.account_warnings_id_seq OWNED BY public.account_warnings.id;


--
-- Name: accounts; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.accounts (
    username character varying DEFAULT ''::character varying NOT NULL,
    domain character varying,
    secret character varying DEFAULT ''::character varying NOT NULL,
    private_key text,
    public_key text DEFAULT ''::text NOT NULL,
    remote_url character varying DEFAULT ''::character varying NOT NULL,
    salmon_url character varying DEFAULT ''::character varying NOT NULL,
    hub_url character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    note text DEFAULT ''::text NOT NULL,
    display_name character varying DEFAULT ''::character varying NOT NULL,
    uri character varying DEFAULT ''::character varying NOT NULL,
    url character varying,
    avatar_file_name character varying,
    avatar_content_type character varying,
    avatar_file_size integer,
    avatar_updated_at timestamp without time zone,
    header_file_name character varying,
    header_content_type character varying,
    header_file_size integer,
    header_updated_at timestamp without time zone,
    avatar_remote_url character varying,
    subscription_expires_at timestamp without time zone,
    locked boolean DEFAULT false NOT NULL,
    header_remote_url character varying DEFAULT ''::character varying NOT NULL,
    last_webfingered_at timestamp without time zone,
    inbox_url character varying DEFAULT ''::character varying NOT NULL,
    outbox_url character varying DEFAULT ''::character varying NOT NULL,
    shared_inbox_url character varying DEFAULT ''::character varying NOT NULL,
    followers_url character varying DEFAULT ''::character varying NOT NULL,
    protocol integer DEFAULT 0 NOT NULL,
    id bigint NOT NULL,
    memorial boolean DEFAULT false NOT NULL,
    moved_to_account_id bigint,
    featured_collection_url character varying,
    fields jsonb,
    actor_type character varying,
    discoverable boolean,
    also_known_as character varying[],
    is_pro boolean DEFAULT false NOT NULL,
    pro_expires_at timestamp without time zone,
    silenced_at timestamp without time zone,
    suspended_at timestamp without time zone,
    is_verified boolean DEFAULT false NOT NULL,
    is_donor boolean DEFAULT false NOT NULL,
    is_investor boolean DEFAULT false NOT NULL
);


ALTER TABLE public.accounts OWNER TO root;

--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.accounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.accounts_id_seq OWNER TO root;

--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.accounts_id_seq OWNED BY public.accounts.id;


--
-- Name: accounts_tags; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.accounts_tags (
    account_id bigint NOT NULL,
    tag_id bigint NOT NULL
);


ALTER TABLE public.accounts_tags OWNER TO root;

--
-- Name: admin_action_logs; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.admin_action_logs (
    id bigint NOT NULL,
    account_id bigint,
    action character varying DEFAULT ''::character varying NOT NULL,
    target_type character varying,
    target_id bigint,
    recorded_changes text DEFAULT ''::text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.admin_action_logs OWNER TO root;

--
-- Name: admin_action_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.admin_action_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.admin_action_logs_id_seq OWNER TO root;

--
-- Name: admin_action_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.admin_action_logs_id_seq OWNED BY public.admin_action_logs.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.ar_internal_metadata OWNER TO root;

--
-- Name: backups; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.backups (
    id bigint NOT NULL,
    user_id bigint,
    dump_file_name character varying,
    dump_content_type character varying,
    dump_file_size integer,
    dump_updated_at timestamp without time zone,
    processed boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.backups OWNER TO root;

--
-- Name: backups_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.backups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.backups_id_seq OWNER TO root;

--
-- Name: backups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.backups_id_seq OWNED BY public.backups.id;


--
-- Name: blocks; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.blocks (
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_id bigint NOT NULL,
    id bigint NOT NULL,
    target_account_id bigint NOT NULL,
    uri character varying
);


ALTER TABLE public.blocks OWNER TO root;

--
-- Name: blocks_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.blocks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.blocks_id_seq OWNER TO root;

--
-- Name: blocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.blocks_id_seq OWNED BY public.blocks.id;


--
-- Name: btc_payments; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.btc_payments (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_id integer NOT NULL,
    btcpay_invoice_id character varying NOT NULL,
    plan character varying NOT NULL,
    success boolean DEFAULT false NOT NULL
);


ALTER TABLE public.btc_payments OWNER TO root;

--
-- Name: btc_payments_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.btc_payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.btc_payments_id_seq OWNER TO root;

--
-- Name: btc_payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.btc_payments_id_seq OWNED BY public.btc_payments.id;


--
-- Name: conversation_mutes; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.conversation_mutes (
    conversation_id bigint NOT NULL,
    account_id bigint NOT NULL,
    id bigint NOT NULL
);


ALTER TABLE public.conversation_mutes OWNER TO root;

--
-- Name: conversation_mutes_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.conversation_mutes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.conversation_mutes_id_seq OWNER TO root;

--
-- Name: conversation_mutes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.conversation_mutes_id_seq OWNED BY public.conversation_mutes.id;


--
-- Name: conversations; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.conversations (
    id bigint NOT NULL,
    uri character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.conversations OWNER TO root;

--
-- Name: conversations_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.conversations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.conversations_id_seq OWNER TO root;

--
-- Name: conversations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.conversations_id_seq OWNED BY public.conversations.id;


--
-- Name: custom_emojis; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.custom_emojis (
    id bigint NOT NULL,
    shortcode character varying DEFAULT ''::character varying NOT NULL,
    domain character varying,
    image_file_name character varying,
    image_content_type character varying,
    image_file_size integer,
    image_updated_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    disabled boolean DEFAULT false NOT NULL,
    uri character varying,
    image_remote_url character varying,
    visible_in_picker boolean DEFAULT true NOT NULL
);


ALTER TABLE public.custom_emojis OWNER TO root;

--
-- Name: custom_emojis_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.custom_emojis_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.custom_emojis_id_seq OWNER TO root;

--
-- Name: custom_emojis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.custom_emojis_id_seq OWNED BY public.custom_emojis.id;


--
-- Name: custom_filters; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.custom_filters (
    id bigint NOT NULL,
    account_id bigint,
    expires_at timestamp without time zone,
    phrase text DEFAULT ''::text NOT NULL,
    context character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    irreversible boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    whole_word boolean DEFAULT true NOT NULL
);


ALTER TABLE public.custom_filters OWNER TO root;

--
-- Name: custom_filters_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.custom_filters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.custom_filters_id_seq OWNER TO root;

--
-- Name: custom_filters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.custom_filters_id_seq OWNED BY public.custom_filters.id;


--
-- Name: deprecated_preview_cards; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.deprecated_preview_cards (
    status_id bigint,
    url character varying DEFAULT ''::character varying NOT NULL,
    title character varying,
    description character varying,
    image_file_name character varying,
    image_content_type character varying,
    image_file_size integer,
    image_updated_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    type integer DEFAULT 0 NOT NULL,
    html text DEFAULT ''::text NOT NULL,
    author_name character varying DEFAULT ''::character varying NOT NULL,
    author_url character varying DEFAULT ''::character varying NOT NULL,
    provider_name character varying DEFAULT ''::character varying NOT NULL,
    provider_url character varying DEFAULT ''::character varying NOT NULL,
    width integer DEFAULT 0 NOT NULL,
    height integer DEFAULT 0 NOT NULL,
    id bigint NOT NULL
);


ALTER TABLE public.deprecated_preview_cards OWNER TO root;

--
-- Name: deprecated_preview_cards_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.deprecated_preview_cards_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.deprecated_preview_cards_id_seq OWNER TO root;

--
-- Name: deprecated_preview_cards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.deprecated_preview_cards_id_seq OWNED BY public.deprecated_preview_cards.id;


--
-- Name: domain_blocks; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.domain_blocks (
    domain character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    severity integer DEFAULT 0,
    reject_media boolean DEFAULT false NOT NULL,
    id bigint NOT NULL,
    reject_reports boolean DEFAULT false NOT NULL
);


ALTER TABLE public.domain_blocks OWNER TO root;

--
-- Name: domain_blocks_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.domain_blocks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.domain_blocks_id_seq OWNER TO root;

--
-- Name: domain_blocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.domain_blocks_id_seq OWNED BY public.domain_blocks.id;


--
-- Name: email_domain_blocks; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.email_domain_blocks (
    id bigint NOT NULL,
    domain character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.email_domain_blocks OWNER TO root;

--
-- Name: email_domain_blocks_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.email_domain_blocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.email_domain_blocks_id_seq OWNER TO root;

--
-- Name: email_domain_blocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.email_domain_blocks_id_seq OWNED BY public.email_domain_blocks.id;


--
-- Name: favourites; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.favourites (
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_id bigint NOT NULL,
    id bigint NOT NULL,
    status_id bigint NOT NULL
);


ALTER TABLE public.favourites OWNER TO root;

--
-- Name: favourites_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.favourites_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.favourites_id_seq OWNER TO root;

--
-- Name: favourites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.favourites_id_seq OWNED BY public.favourites.id;


--
-- Name: featured_tags; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.featured_tags (
    id bigint NOT NULL,
    account_id bigint,
    tag_id bigint,
    statuses_count bigint DEFAULT 0 NOT NULL,
    last_status_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.featured_tags OWNER TO root;

--
-- Name: featured_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.featured_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.featured_tags_id_seq OWNER TO root;

--
-- Name: featured_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.featured_tags_id_seq OWNED BY public.featured_tags.id;


--
-- Name: follow_requests; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.follow_requests (
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_id bigint NOT NULL,
    id bigint NOT NULL,
    target_account_id bigint NOT NULL,
    show_reblogs boolean DEFAULT true NOT NULL,
    uri character varying
);


ALTER TABLE public.follow_requests OWNER TO root;

--
-- Name: follow_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.follow_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.follow_requests_id_seq OWNER TO root;

--
-- Name: follow_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.follow_requests_id_seq OWNED BY public.follow_requests.id;


--
-- Name: follows; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.follows (
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_id bigint NOT NULL,
    id bigint NOT NULL,
    target_account_id bigint NOT NULL,
    show_reblogs boolean DEFAULT true NOT NULL,
    uri character varying
);


ALTER TABLE public.follows OWNER TO root;

--
-- Name: follows_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.follows_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.follows_id_seq OWNER TO root;

--
-- Name: follows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.follows_id_seq OWNED BY public.follows.id;


--
-- Name: group_accounts; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.group_accounts (
    id bigint NOT NULL,
    group_id bigint NOT NULL,
    account_id bigint NOT NULL,
    write_permissions boolean DEFAULT false NOT NULL,
    role character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    unread_count integer DEFAULT 0
);


ALTER TABLE public.group_accounts OWNER TO root;

--
-- Name: group_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.group_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.group_accounts_id_seq OWNER TO root;

--
-- Name: group_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.group_accounts_id_seq OWNED BY public.group_accounts.id;


--
-- Name: group_removed_accounts; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.group_removed_accounts (
    id bigint NOT NULL,
    group_id bigint NOT NULL,
    account_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.group_removed_accounts OWNER TO root;

--
-- Name: group_removed_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.group_removed_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.group_removed_accounts_id_seq OWNER TO root;

--
-- Name: group_removed_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.group_removed_accounts_id_seq OWNED BY public.group_removed_accounts.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.groups (
    id bigint NOT NULL,
    account_id bigint,
    title character varying NOT NULL,
    description character varying NOT NULL,
    cover_image_file_name character varying,
    cover_image_content_type character varying,
    cover_image_file_size integer,
    cover_image_updated_at timestamp without time zone,
    is_nsfw boolean DEFAULT false NOT NULL,
    is_featured boolean DEFAULT false NOT NULL,
    is_archived boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    member_count integer DEFAULT 0
);


ALTER TABLE public.groups OWNER TO root;

--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.groups_id_seq OWNER TO root;

--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.groups_id_seq OWNED BY public.groups.id;


--
-- Name: identities; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.identities (
    provider character varying DEFAULT ''::character varying NOT NULL,
    uid character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    id bigint NOT NULL,
    user_id bigint
);


ALTER TABLE public.identities OWNER TO root;

--
-- Name: identities_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.identities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.identities_id_seq OWNER TO root;

--
-- Name: identities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.identities_id_seq OWNED BY public.identities.id;


--
-- Name: imports; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.imports (
    type integer NOT NULL,
    approved boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data_file_name character varying,
    data_content_type character varying,
    data_file_size integer,
    data_updated_at timestamp without time zone,
    account_id bigint NOT NULL,
    id bigint NOT NULL,
    overwrite boolean DEFAULT false NOT NULL
);


ALTER TABLE public.imports OWNER TO root;

--
-- Name: imports_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.imports_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.imports_id_seq OWNER TO root;

--
-- Name: imports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.imports_id_seq OWNED BY public.imports.id;


--
-- Name: invites; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.invites (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    code character varying DEFAULT ''::character varying NOT NULL,
    expires_at timestamp without time zone,
    max_uses integer,
    uses integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    autofollow boolean DEFAULT false NOT NULL
);


ALTER TABLE public.invites OWNER TO root;

--
-- Name: invites_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.invites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.invites_id_seq OWNER TO root;

--
-- Name: invites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.invites_id_seq OWNED BY public.invites.id;


--
-- Name: list_accounts; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.list_accounts (
    id bigint NOT NULL,
    list_id bigint NOT NULL,
    account_id bigint NOT NULL,
    follow_id bigint NOT NULL
);


ALTER TABLE public.list_accounts OWNER TO root;

--
-- Name: list_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.list_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.list_accounts_id_seq OWNER TO root;

--
-- Name: list_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.list_accounts_id_seq OWNED BY public.list_accounts.id;


--
-- Name: lists; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.lists (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    title character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.lists OWNER TO root;

--
-- Name: lists_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.lists_id_seq OWNER TO root;

--
-- Name: lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.lists_id_seq OWNED BY public.lists.id;


--
-- Name: media_attachments; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.media_attachments (
    status_id bigint,
    file_file_name character varying,
    file_content_type character varying,
    file_file_size integer,
    file_updated_at timestamp without time zone,
    remote_url character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    shortcode character varying,
    type integer DEFAULT 0 NOT NULL,
    file_meta json,
    account_id bigint,
    id bigint NOT NULL,
    description text,
    scheduled_status_id bigint,
    blurhash character varying
);


ALTER TABLE public.media_attachments OWNER TO root;

--
-- Name: media_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.media_attachments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.media_attachments_id_seq OWNER TO root;

--
-- Name: media_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.media_attachments_id_seq OWNED BY public.media_attachments.id;


--
-- Name: mentions; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.mentions (
    status_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_id bigint,
    id bigint NOT NULL,
    silent boolean DEFAULT false NOT NULL
);


ALTER TABLE public.mentions OWNER TO root;

--
-- Name: mentions_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.mentions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mentions_id_seq OWNER TO root;

--
-- Name: mentions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.mentions_id_seq OWNED BY public.mentions.id;


--
-- Name: mutes; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.mutes (
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    hide_notifications boolean DEFAULT true NOT NULL,
    account_id bigint NOT NULL,
    id bigint NOT NULL,
    target_account_id bigint NOT NULL
);


ALTER TABLE public.mutes OWNER TO root;

--
-- Name: mutes_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.mutes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mutes_id_seq OWNER TO root;

--
-- Name: mutes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.mutes_id_seq OWNED BY public.mutes.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.notifications (
    activity_id bigint NOT NULL,
    activity_type character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_id bigint NOT NULL,
    from_account_id bigint NOT NULL,
    id bigint NOT NULL
);


ALTER TABLE public.notifications OWNER TO root;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.notifications_id_seq OWNER TO root;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: oauth_access_grants; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.oauth_access_grants (
    token character varying NOT NULL,
    expires_in integer NOT NULL,
    redirect_uri text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    revoked_at timestamp without time zone,
    scopes character varying,
    application_id bigint NOT NULL,
    id bigint NOT NULL,
    resource_owner_id bigint NOT NULL
);


ALTER TABLE public.oauth_access_grants OWNER TO root;

--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.oauth_access_grants_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.oauth_access_grants_id_seq OWNER TO root;

--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.oauth_access_grants_id_seq OWNED BY public.oauth_access_grants.id;


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.oauth_access_tokens (
    token character varying NOT NULL,
    refresh_token character varying,
    expires_in integer,
    revoked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    scopes character varying,
    application_id bigint,
    id bigint NOT NULL,
    resource_owner_id bigint
);


ALTER TABLE public.oauth_access_tokens OWNER TO root;

--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.oauth_access_tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.oauth_access_tokens_id_seq OWNER TO root;

--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.oauth_access_tokens_id_seq OWNED BY public.oauth_access_tokens.id;


--
-- Name: oauth_applications; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.oauth_applications (
    name character varying NOT NULL,
    uid character varying NOT NULL,
    secret character varying NOT NULL,
    redirect_uri text NOT NULL,
    scopes character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    superapp boolean DEFAULT false NOT NULL,
    website character varying,
    owner_type character varying,
    id bigint NOT NULL,
    owner_id bigint,
    confidential boolean DEFAULT true NOT NULL
);


ALTER TABLE public.oauth_applications OWNER TO root;

--
-- Name: oauth_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.oauth_applications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.oauth_applications_id_seq OWNER TO root;

--
-- Name: oauth_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.oauth_applications_id_seq OWNED BY public.oauth_applications.id;


--
-- Name: pghero_space_stats; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.pghero_space_stats (
    id bigint NOT NULL,
    database text,
    schema text,
    relation text,
    size bigint,
    captured_at timestamp without time zone
);


ALTER TABLE public.pghero_space_stats OWNER TO root;

--
-- Name: pghero_space_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.pghero_space_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pghero_space_stats_id_seq OWNER TO root;

--
-- Name: pghero_space_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.pghero_space_stats_id_seq OWNED BY public.pghero_space_stats.id;


--
-- Name: poll_votes; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.poll_votes (
    id bigint NOT NULL,
    account_id bigint,
    poll_id bigint,
    choice integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    uri character varying
);


ALTER TABLE public.poll_votes OWNER TO root;

--
-- Name: poll_votes_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.poll_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.poll_votes_id_seq OWNER TO root;

--
-- Name: poll_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.poll_votes_id_seq OWNED BY public.poll_votes.id;


--
-- Name: polls; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.polls (
    id bigint NOT NULL,
    account_id bigint,
    status_id bigint,
    expires_at timestamp without time zone,
    options character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    cached_tallies bigint[] DEFAULT '{}'::bigint[] NOT NULL,
    multiple boolean DEFAULT false NOT NULL,
    hide_totals boolean DEFAULT false NOT NULL,
    votes_count bigint DEFAULT 0 NOT NULL,
    last_fetched_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    lock_version integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.polls OWNER TO root;

--
-- Name: polls_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.polls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.polls_id_seq OWNER TO root;

--
-- Name: polls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.polls_id_seq OWNED BY public.polls.id;


--
-- Name: preview_cards; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.preview_cards (
    id bigint NOT NULL,
    url character varying DEFAULT ''::character varying NOT NULL,
    title character varying DEFAULT ''::character varying NOT NULL,
    description character varying DEFAULT ''::character varying NOT NULL,
    image_file_name character varying,
    image_content_type character varying,
    image_file_size integer,
    image_updated_at timestamp without time zone,
    type integer DEFAULT 0 NOT NULL,
    html text DEFAULT ''::text NOT NULL,
    author_name character varying DEFAULT ''::character varying NOT NULL,
    author_url character varying DEFAULT ''::character varying NOT NULL,
    provider_name character varying DEFAULT ''::character varying NOT NULL,
    provider_url character varying DEFAULT ''::character varying NOT NULL,
    width integer DEFAULT 0 NOT NULL,
    height integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    embed_url character varying DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.preview_cards OWNER TO root;

--
-- Name: preview_cards_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.preview_cards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.preview_cards_id_seq OWNER TO root;

--
-- Name: preview_cards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.preview_cards_id_seq OWNED BY public.preview_cards.id;


--
-- Name: preview_cards_statuses; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.preview_cards_statuses (
    preview_card_id bigint NOT NULL,
    status_id bigint NOT NULL
);


ALTER TABLE public.preview_cards_statuses OWNER TO root;

--
-- Name: relays; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.relays (
    id bigint NOT NULL,
    inbox_url character varying DEFAULT ''::character varying NOT NULL,
    follow_activity_id character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    state integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.relays OWNER TO root;

--
-- Name: relays_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.relays_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.relays_id_seq OWNER TO root;

--
-- Name: relays_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.relays_id_seq OWNED BY public.relays.id;


--
-- Name: report_notes; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.report_notes (
    id bigint NOT NULL,
    content text NOT NULL,
    report_id bigint NOT NULL,
    account_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.report_notes OWNER TO root;

--
-- Name: report_notes_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.report_notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.report_notes_id_seq OWNER TO root;

--
-- Name: report_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.report_notes_id_seq OWNED BY public.report_notes.id;


--
-- Name: reports; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.reports (
    status_ids bigint[] DEFAULT '{}'::integer[] NOT NULL,
    comment text DEFAULT ''::text NOT NULL,
    action_taken boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_id bigint NOT NULL,
    action_taken_by_account_id bigint,
    id bigint NOT NULL,
    target_account_id bigint NOT NULL,
    assigned_account_id bigint,
    uri character varying
);


ALTER TABLE public.reports OWNER TO root;

--
-- Name: reports_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.reports_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reports_id_seq OWNER TO root;

--
-- Name: reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.reports_id_seq OWNED BY public.reports.id;


--
-- Name: scheduled_statuses; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.scheduled_statuses (
    id bigint NOT NULL,
    account_id bigint,
    scheduled_at timestamp without time zone,
    params jsonb
);


ALTER TABLE public.scheduled_statuses OWNER TO root;

--
-- Name: scheduled_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.scheduled_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.scheduled_statuses_id_seq OWNER TO root;

--
-- Name: scheduled_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.scheduled_statuses_id_seq OWNED BY public.scheduled_statuses.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO root;

--
-- Name: session_activations; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.session_activations (
    id bigint NOT NULL,
    session_id character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_agent character varying DEFAULT ''::character varying NOT NULL,
    ip inet,
    access_token_id bigint,
    user_id bigint NOT NULL,
    web_push_subscription_id bigint
);


ALTER TABLE public.session_activations OWNER TO root;

--
-- Name: session_activations_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.session_activations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.session_activations_id_seq OWNER TO root;

--
-- Name: session_activations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.session_activations_id_seq OWNED BY public.session_activations.id;


--
-- Name: settings; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.settings (
    var character varying NOT NULL,
    value text,
    thing_type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id bigint NOT NULL,
    thing_id bigint
);


ALTER TABLE public.settings OWNER TO root;

--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.settings_id_seq OWNER TO root;

--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.settings_id_seq OWNED BY public.settings.id;


--
-- Name: site_uploads; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.site_uploads (
    id bigint NOT NULL,
    var character varying DEFAULT ''::character varying NOT NULL,
    file_file_name character varying,
    file_content_type character varying,
    file_file_size integer,
    file_updated_at timestamp without time zone,
    meta json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.site_uploads OWNER TO root;

--
-- Name: site_uploads_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.site_uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_uploads_id_seq OWNER TO root;

--
-- Name: site_uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.site_uploads_id_seq OWNED BY public.site_uploads.id;


--
-- Name: status_pins; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.status_pins (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    status_id bigint NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.status_pins OWNER TO root;

--
-- Name: status_pins_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.status_pins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.status_pins_id_seq OWNER TO root;

--
-- Name: status_pins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.status_pins_id_seq OWNED BY public.status_pins.id;


--
-- Name: status_stats; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.status_stats (
    id bigint NOT NULL,
    status_id bigint NOT NULL,
    replies_count bigint DEFAULT 0 NOT NULL,
    reblogs_count bigint DEFAULT 0 NOT NULL,
    favourites_count bigint DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.status_stats OWNER TO root;

--
-- Name: status_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.status_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.status_stats_id_seq OWNER TO root;

--
-- Name: status_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.status_stats_id_seq OWNED BY public.status_stats.id;


--
-- Name: statuses; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.statuses (
    id bigint DEFAULT public.timestamp_id('statuses'::text) NOT NULL,
    uri character varying,
    text text DEFAULT ''::text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    in_reply_to_id bigint,
    reblog_of_id bigint,
    url character varying,
    sensitive boolean DEFAULT false NOT NULL,
    visibility integer DEFAULT 0 NOT NULL,
    spoiler_text text DEFAULT ''::text NOT NULL,
    reply boolean DEFAULT false NOT NULL,
    language character varying,
    conversation_id bigint,
    local boolean,
    account_id bigint NOT NULL,
    application_id bigint,
    in_reply_to_account_id bigint,
    poll_id bigint,
    group_id integer,
    quote_of_id bigint
);


ALTER TABLE public.statuses OWNER TO root;

--
-- Name: statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.statuses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.statuses_id_seq OWNER TO root;

--
-- Name: statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.statuses_id_seq OWNED BY public.statuses.id;


--
-- Name: statuses_tags; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.statuses_tags (
    status_id bigint NOT NULL,
    tag_id bigint NOT NULL
);


ALTER TABLE public.statuses_tags OWNER TO root;

--
-- Name: stream_entries; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.stream_entries (
    activity_id bigint,
    activity_type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    hidden boolean DEFAULT false NOT NULL,
    account_id bigint,
    id bigint NOT NULL
);


ALTER TABLE public.stream_entries OWNER TO root;

--
-- Name: stream_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.stream_entries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stream_entries_id_seq OWNER TO root;

--
-- Name: stream_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.stream_entries_id_seq OWNED BY public.stream_entries.id;


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.subscriptions (
    callback_url character varying DEFAULT ''::character varying NOT NULL,
    secret character varying,
    expires_at timestamp without time zone,
    confirmed boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    last_successful_delivery_at timestamp without time zone,
    domain character varying,
    account_id bigint NOT NULL,
    id bigint NOT NULL
);


ALTER TABLE public.subscriptions OWNER TO root;

--
-- Name: subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.subscriptions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.subscriptions_id_seq OWNER TO root;

--
-- Name: subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.subscriptions_id_seq OWNED BY public.subscriptions.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.tags (
    name character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    id bigint NOT NULL
);


ALTER TABLE public.tags OWNER TO root;

--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.tags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tags_id_seq OWNER TO root;

--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: tombstones; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.tombstones (
    id bigint NOT NULL,
    account_id bigint,
    uri character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    by_moderator boolean
);


ALTER TABLE public.tombstones OWNER TO root;

--
-- Name: tombstones_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.tombstones_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tombstones_id_seq OWNER TO root;

--
-- Name: tombstones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.tombstones_id_seq OWNED BY public.tombstones.id;


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.transactions (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_id integer NOT NULL,
    payment_type character varying,
    provider_type character varying,
    provider_response text,
    amount integer NOT NULL,
    success boolean DEFAULT false NOT NULL
);


ALTER TABLE public.transactions OWNER TO root;

--
-- Name: transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.transactions_id_seq OWNER TO root;

--
-- Name: transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.transactions_id_seq OWNED BY public.transactions.id;


--
-- Name: user_invite_requests; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.user_invite_requests (
    id bigint NOT NULL,
    user_id bigint,
    text text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.user_invite_requests OWNER TO root;

--
-- Name: user_invite_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.user_invite_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_invite_requests_id_seq OWNER TO root;

--
-- Name: user_invite_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.user_invite_requests_id_seq OWNED BY public.user_invite_requests.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.users (
    email character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    admin boolean DEFAULT false NOT NULL,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    locale character varying,
    encrypted_otp_secret character varying,
    encrypted_otp_secret_iv character varying,
    encrypted_otp_secret_salt character varying,
    consumed_timestep integer,
    otp_required_for_login boolean DEFAULT false NOT NULL,
    last_emailed_at timestamp without time zone,
    otp_backup_codes character varying[],
    filtered_languages character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    account_id bigint NOT NULL,
    id bigint NOT NULL,
    disabled boolean DEFAULT false NOT NULL,
    moderator boolean DEFAULT false NOT NULL,
    invite_id bigint,
    remember_token character varying,
    chosen_languages character varying[],
    created_by_application_id bigint,
    approved boolean DEFAULT true NOT NULL
);


ALTER TABLE public.users OWNER TO root;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO root;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: web_push_subscriptions; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.web_push_subscriptions (
    id bigint NOT NULL,
    endpoint character varying NOT NULL,
    key_p256dh character varying NOT NULL,
    key_auth character varying NOT NULL,
    data json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    access_token_id bigint,
    user_id bigint
);


ALTER TABLE public.web_push_subscriptions OWNER TO root;

--
-- Name: web_push_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.web_push_subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.web_push_subscriptions_id_seq OWNER TO root;

--
-- Name: web_push_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.web_push_subscriptions_id_seq OWNED BY public.web_push_subscriptions.id;


--
-- Name: web_settings; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.web_settings (
    data json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    id bigint NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.web_settings OWNER TO root;

--
-- Name: web_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.web_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.web_settings_id_seq OWNER TO root;

--
-- Name: web_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.web_settings_id_seq OWNED BY public.web_settings.id;


--
-- Name: account_conversations id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_conversations ALTER COLUMN id SET DEFAULT nextval('public.account_conversations_id_seq'::regclass);


--
-- Name: account_domain_blocks id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_domain_blocks ALTER COLUMN id SET DEFAULT nextval('public.account_domain_blocks_id_seq'::regclass);


--
-- Name: account_identity_proofs id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_identity_proofs ALTER COLUMN id SET DEFAULT nextval('public.account_identity_proofs_id_seq'::regclass);


--
-- Name: account_moderation_notes id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_moderation_notes ALTER COLUMN id SET DEFAULT nextval('public.account_moderation_notes_id_seq'::regclass);


--
-- Name: account_pins id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_pins ALTER COLUMN id SET DEFAULT nextval('public.account_pins_id_seq'::regclass);


--
-- Name: account_stats id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_stats ALTER COLUMN id SET DEFAULT nextval('public.account_stats_id_seq'::regclass);


--
-- Name: account_tag_stats id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_tag_stats ALTER COLUMN id SET DEFAULT nextval('public.account_tag_stats_id_seq'::regclass);


--
-- Name: account_verification_requests id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_verification_requests ALTER COLUMN id SET DEFAULT nextval('public.account_verification_requests_id_seq'::regclass);


--
-- Name: account_warning_presets id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_warning_presets ALTER COLUMN id SET DEFAULT nextval('public.account_warning_presets_id_seq'::regclass);


--
-- Name: account_warnings id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_warnings ALTER COLUMN id SET DEFAULT nextval('public.account_warnings_id_seq'::regclass);


--
-- Name: accounts id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.accounts ALTER COLUMN id SET DEFAULT nextval('public.accounts_id_seq'::regclass);


--
-- Name: admin_action_logs id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.admin_action_logs ALTER COLUMN id SET DEFAULT nextval('public.admin_action_logs_id_seq'::regclass);


--
-- Name: backups id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.backups ALTER COLUMN id SET DEFAULT nextval('public.backups_id_seq'::regclass);


--
-- Name: blocks id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.blocks ALTER COLUMN id SET DEFAULT nextval('public.blocks_id_seq'::regclass);


--
-- Name: btc_payments id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.btc_payments ALTER COLUMN id SET DEFAULT nextval('public.btc_payments_id_seq'::regclass);


--
-- Name: conversation_mutes id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.conversation_mutes ALTER COLUMN id SET DEFAULT nextval('public.conversation_mutes_id_seq'::regclass);


--
-- Name: conversations id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.conversations ALTER COLUMN id SET DEFAULT nextval('public.conversations_id_seq'::regclass);


--
-- Name: custom_emojis id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.custom_emojis ALTER COLUMN id SET DEFAULT nextval('public.custom_emojis_id_seq'::regclass);


--
-- Name: custom_filters id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.custom_filters ALTER COLUMN id SET DEFAULT nextval('public.custom_filters_id_seq'::regclass);


--
-- Name: deprecated_preview_cards id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.deprecated_preview_cards ALTER COLUMN id SET DEFAULT nextval('public.deprecated_preview_cards_id_seq'::regclass);


--
-- Name: domain_blocks id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.domain_blocks ALTER COLUMN id SET DEFAULT nextval('public.domain_blocks_id_seq'::regclass);


--
-- Name: email_domain_blocks id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.email_domain_blocks ALTER COLUMN id SET DEFAULT nextval('public.email_domain_blocks_id_seq'::regclass);


--
-- Name: favourites id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.favourites ALTER COLUMN id SET DEFAULT nextval('public.favourites_id_seq'::regclass);


--
-- Name: featured_tags id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.featured_tags ALTER COLUMN id SET DEFAULT nextval('public.featured_tags_id_seq'::regclass);


--
-- Name: follow_requests id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.follow_requests ALTER COLUMN id SET DEFAULT nextval('public.follow_requests_id_seq'::regclass);


--
-- Name: follows id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.follows ALTER COLUMN id SET DEFAULT nextval('public.follows_id_seq'::regclass);


--
-- Name: group_accounts id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.group_accounts ALTER COLUMN id SET DEFAULT nextval('public.group_accounts_id_seq'::regclass);


--
-- Name: group_removed_accounts id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.group_removed_accounts ALTER COLUMN id SET DEFAULT nextval('public.group_removed_accounts_id_seq'::regclass);


--
-- Name: groups id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.groups ALTER COLUMN id SET DEFAULT nextval('public.groups_id_seq'::regclass);


--
-- Name: identities id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.identities ALTER COLUMN id SET DEFAULT nextval('public.identities_id_seq'::regclass);


--
-- Name: imports id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.imports ALTER COLUMN id SET DEFAULT nextval('public.imports_id_seq'::regclass);


--
-- Name: invites id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.invites ALTER COLUMN id SET DEFAULT nextval('public.invites_id_seq'::regclass);


--
-- Name: list_accounts id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.list_accounts ALTER COLUMN id SET DEFAULT nextval('public.list_accounts_id_seq'::regclass);


--
-- Name: lists id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.lists ALTER COLUMN id SET DEFAULT nextval('public.lists_id_seq'::regclass);


--
-- Name: media_attachments id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.media_attachments ALTER COLUMN id SET DEFAULT nextval('public.media_attachments_id_seq'::regclass);


--
-- Name: mentions id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.mentions ALTER COLUMN id SET DEFAULT nextval('public.mentions_id_seq'::regclass);


--
-- Name: mutes id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.mutes ALTER COLUMN id SET DEFAULT nextval('public.mutes_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: oauth_access_grants id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.oauth_access_grants ALTER COLUMN id SET DEFAULT nextval('public.oauth_access_grants_id_seq'::regclass);


--
-- Name: oauth_access_tokens id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.oauth_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.oauth_access_tokens_id_seq'::regclass);


--
-- Name: oauth_applications id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.oauth_applications ALTER COLUMN id SET DEFAULT nextval('public.oauth_applications_id_seq'::regclass);


--
-- Name: pghero_space_stats id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.pghero_space_stats ALTER COLUMN id SET DEFAULT nextval('public.pghero_space_stats_id_seq'::regclass);


--
-- Name: poll_votes id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.poll_votes ALTER COLUMN id SET DEFAULT nextval('public.poll_votes_id_seq'::regclass);


--
-- Name: polls id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.polls ALTER COLUMN id SET DEFAULT nextval('public.polls_id_seq'::regclass);


--
-- Name: preview_cards id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.preview_cards ALTER COLUMN id SET DEFAULT nextval('public.preview_cards_id_seq'::regclass);


--
-- Name: relays id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.relays ALTER COLUMN id SET DEFAULT nextval('public.relays_id_seq'::regclass);


--
-- Name: report_notes id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.report_notes ALTER COLUMN id SET DEFAULT nextval('public.report_notes_id_seq'::regclass);


--
-- Name: reports id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.reports ALTER COLUMN id SET DEFAULT nextval('public.reports_id_seq'::regclass);


--
-- Name: scheduled_statuses id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.scheduled_statuses ALTER COLUMN id SET DEFAULT nextval('public.scheduled_statuses_id_seq'::regclass);


--
-- Name: session_activations id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.session_activations ALTER COLUMN id SET DEFAULT nextval('public.session_activations_id_seq'::regclass);


--
-- Name: settings id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.settings ALTER COLUMN id SET DEFAULT nextval('public.settings_id_seq'::regclass);


--
-- Name: site_uploads id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.site_uploads ALTER COLUMN id SET DEFAULT nextval('public.site_uploads_id_seq'::regclass);


--
-- Name: status_pins id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.status_pins ALTER COLUMN id SET DEFAULT nextval('public.status_pins_id_seq'::regclass);


--
-- Name: status_stats id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.status_stats ALTER COLUMN id SET DEFAULT nextval('public.status_stats_id_seq'::regclass);


--
-- Name: stream_entries id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.stream_entries ALTER COLUMN id SET DEFAULT nextval('public.stream_entries_id_seq'::regclass);


--
-- Name: subscriptions id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.subscriptions ALTER COLUMN id SET DEFAULT nextval('public.subscriptions_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: tombstones id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.tombstones ALTER COLUMN id SET DEFAULT nextval('public.tombstones_id_seq'::regclass);


--
-- Name: transactions id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.transactions ALTER COLUMN id SET DEFAULT nextval('public.transactions_id_seq'::regclass);


--
-- Name: user_invite_requests id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.user_invite_requests ALTER COLUMN id SET DEFAULT nextval('public.user_invite_requests_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: web_push_subscriptions id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.web_push_subscriptions ALTER COLUMN id SET DEFAULT nextval('public.web_push_subscriptions_id_seq'::regclass);


--
-- Name: web_settings id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.web_settings ALTER COLUMN id SET DEFAULT nextval('public.web_settings_id_seq'::regclass);


--
-- Data for Name: account_conversations; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.account_conversations (id, account_id, conversation_id, participant_account_ids, status_ids, last_status_id, lock_version, unread) FROM stdin;
\.


--
-- Data for Name: account_domain_blocks; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.account_domain_blocks (domain, created_at, updated_at, account_id, id) FROM stdin;
\.


--
-- Data for Name: account_identity_proofs; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.account_identity_proofs (id, account_id, provider, provider_username, token, verified, live, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: account_moderation_notes; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.account_moderation_notes (id, content, account_id, target_account_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: account_pins; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.account_pins (id, account_id, target_account_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: account_stats; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.account_stats (id, account_id, statuses_count, following_count, followers_count, created_at, updated_at, last_status_at) FROM stdin;
7	7	0	0	0	2019-08-12 09:30:36.992986	2019-08-12 09:30:36.992986	\N
6	6	1	0	1	2019-08-12 08:34:58.281607	2019-08-12 09:54:18.924486	2019-08-12 09:22:24.696638
8	8	2	1	0	2019-08-12 09:51:56.020002	2019-08-12 09:58:40.0123	2019-08-12 09:58:40.011948
\.


--
-- Data for Name: account_tag_stats; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.account_tag_stats (id, tag_id, accounts_count, hidden, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: account_verification_requests; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.account_verification_requests (id, account_id, image_file_name, image_content_type, image_file_size, image_updated_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: account_warning_presets; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.account_warning_presets (id, text, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: account_warnings; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.account_warnings (id, account_id, target_account_id, action, text, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.accounts (username, domain, secret, private_key, public_key, remote_url, salmon_url, hub_url, created_at, updated_at, note, display_name, uri, url, avatar_file_name, avatar_content_type, avatar_file_size, avatar_updated_at, header_file_name, header_content_type, header_file_size, header_updated_at, avatar_remote_url, subscription_expires_at, locked, header_remote_url, last_webfingered_at, inbox_url, outbox_url, shared_inbox_url, followers_url, protocol, id, memorial, moved_to_account_id, featured_collection_url, fields, actor_type, discoverable, also_known_as, is_pro, pro_expires_at, silenced_at, suspended_at, is_verified, is_donor, is_investor) FROM stdin;
c	\N		-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEAvBnyhuuQ7F0dHkfbJcGXENC0cLBlcYwHnvvShX7tvsEGLPoS\n/xE0OlhoXP99aZ+6j8xIlXIIZCYLlEIc82esV3Tkux7CJKo/uRbSp302MPtnlHDd\nZ/U7qLSDIBbZuMkEo1ooprCuVPleqyK/9ejRowjPaalopSlx/0Ep3fz2Q82U1zkg\nsiraIueeMN/td3ECMo6T1lWdxWhNJS92vaCTLkxp4BKql9lkhw9wJXRA6Yoy0aEj\nvu/rx3d8DDxwbNlAAMqrOj99xlCKDqqP4ybEAIuJgITQx9YijbPXz99uBda2ozw9\ntL6HWhCLg76oQEl55xP+7x4sa4jVVg7bDIvF9wIDAQABAoIBADG/lxIx+UlaMxpQ\nHNi2g7Kx0BdBwAKw608UARDHii96M5zvotiM/0gzG58E/3FRCnF/sO69kxSRr1xN\nxARoNf+HbftDXkt+L45PR/V+OzfnNfTfiN82z8mFvGxfPsQNfkmJzdiQP/s/XNdc\nQHLUWaWJ7flfEcsk0/6TiHQqtCMoJnIJWljjiZ04IH0JEMYYjYratpR9cXHbScRV\njaIVXogRtPbkkVGl9jGPCEVN0prTiyB+/Ds+V2jo2RqIlAVSwyDuJYv/dE2ii0Yq\nbC0SMBWpZmlEeP3LcghEx5Wl8HG89UqKGYIRPzplHD+jgLRsEONsgVqDY/VJzTVj\nXuL7DukCgYEA84LbgRY4qYjBTuoQSmwuH/sHVmXX2mfAeiQWiWRtWTjthNQYQmtg\ndp5hYrqBKJocq/V1ZC4XdlDmkPEr1WiIVzuJCHcYdJjxmCy7UoUGFzJOcnbcEMw5\n1RkRLUjEmt4Sz9KaC12ZCppcXlw44YcTPiZlwlacZiim+WB43pjz0XUCgYEAxb+Y\nak1rEian5tbGsHtbaAmXYGzm5L2Snur0APuEXGyOoRkhQyxC7y+oqf/Lng2r+RY+\nMw9eFXFdCGrmFzcVAx+3Ma9NX4D0LWhx6lOAw2ArRuGPyR8JQoP/nOOgyG/7cweG\nripiNxYZuNkhMNfzWjrNzWzhrkP6j6/OX0EggDsCgYEAhUPGER0yIUXgVOmvxKrz\nizj8SQIvYS2Kns2FL+ewGDYZdqoEJMVS41fGABwFd0zwCAOrHQpEeNHJfOUfkglF\nJEhGtEVJMvZIsXk5gu2d6a/0UpxNzzuVItQ3HEtInWCPdwDQoQu2J6FWj6V006fy\nlf65jeOMcDQrPSrYuymFtckCgYAH5kF2baVLUlP+urGxNxxNqaRsa61FkfUbeBNL\nPsDo2EVSViioAEqkN2krcVZ29+DY0HSnoYOGo8KtpWePodmrCEdPKsuSdxpJ/hQe\n4jsQkvTnnfcad6ztBUzevZEcsKyAydotdu/5d16LrdDPnLDR9+tku2bAiWKm/sTl\ntTpRJQKBgQCa2XOaGua+GFWZouyo4TGpV7Jw+HPpWnq+LPw9z2JwSZnLVf9sP9hZ\nHN9v1bKt0GEB4MbtK1k92NtHVXreyYQR4J+qIm3Ol1SBSy9fD27B/inbydrS6bDo\nTvq1dmRh+SW1RZtvyK3YytzG7hPAlbPYfhoHFXTu5pWCAMJHGQlWEQ==\n-----END RSA PRIVATE KEY-----\n	-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvBnyhuuQ7F0dHkfbJcGX\nENC0cLBlcYwHnvvShX7tvsEGLPoS/xE0OlhoXP99aZ+6j8xIlXIIZCYLlEIc82es\nV3Tkux7CJKo/uRbSp302MPtnlHDdZ/U7qLSDIBbZuMkEo1ooprCuVPleqyK/9ejR\nowjPaalopSlx/0Ep3fz2Q82U1zkgsiraIueeMN/td3ECMo6T1lWdxWhNJS92vaCT\nLkxp4BKql9lkhw9wJXRA6Yoy0aEjvu/rx3d8DDxwbNlAAMqrOj99xlCKDqqP4ybE\nAIuJgITQx9YijbPXz99uBda2ozw9tL6HWhCLg76oQEl55xP+7x4sa4jVVg7bDIvF\n9wIDAQAB\n-----END PUBLIC KEY-----\n				2019-08-12 09:30:36.899889	2019-08-12 09:30:36.899889				\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f		\N					0	7	f	\N	\N	\N	\N	\N	\N	f	\N	\N	\N	f	f	f
csinger	\N		-----BEGIN RSA PRIVATE KEY-----\nMIIEogIBAAKCAQEAqUtQDFV2y9xOfymvlABSiFhoEwX8fJ66h9jRKIcRQuIYNOOc\nPyXCXCJNbB7K/0I+A3ye05uPNDntcCkHYPDBrhvblM/mKJuq8rcLuGkrGMsBJJw7\n7cGm++EEKlv7pvrYv6dJwkLVyzI+iHk9RtbNQfsQi4O09Zg3AG91FrkXyBRBxHkU\nZ+f0wGjVa8R9KJrjVzP5cuIO6y2ZTrwz6D0QhYJAB9yR6PjwLE3MUsoOTuE9bKx9\nsbl5rsBtgXso96n9hLn9NooOctsKRy88BKc2Wa5hZfAxdsPoqGRMZNHzGhNvXBHf\nmcIqv5al3fMuaSkQYDymBKw2Xie29dAMRFfMzQIDAQABAoIBAB9Ri3F8rglwrCTi\nNVUP6jTHBhne1aLISoGvHqJ8ujjBUvEV2mXkOlyJDAGggLVQL+C9QTSsZoWm4cIK\nFQ9d+raW+LxC6bVBdxKHwmdPLWXcyE1ZicymMpoOOpMLiTaO2WI7NG33p0178g2V\nQDzGqBo4tArbRrLYgfRWqjaV70xYBfwG00LAulrCveScFvYONMnzADbXn4MEx4P/\n2qjHAYjggR0ehMeoZei7SkSn07jrwlooYufTWCU4nbrXajX3HPJegnD+uxyZZ4vZ\nMRHqkJizKHruhT5seIKUp5WkF9h/NIxTBl24K7HMVNNjfqTegqMKeWLS0XsIMDlo\nIR/YKpECgYEA0HIWyvBol93dZ7BOe75kt0hkt+NSl+axYwTRoUB/lVD63wCa6BkZ\nsyZyznWPgOXzwE3xGtMvZZmwYW+DEhwVQ1eTyg1/QbozJDliRGW0b7Ii7dW4QrA8\na/imDtnOqy8kYU+vB6Yq5BHNvOz/cRX8feiHepqcmUM75XPNRr4/NJcCgYEAz+qm\nNVT0EF/caZt+NQ85EXMRmK9nzZ5IIX63q+VG2YzU3y2b/vycez8YKYgMWC8VSPen\nQxuOjjNIksvXt/q4DgOwyFQCA3dFwJyGAEE0bupbtM6n7HmiSJgnbrws+RqBUYrV\nJXh6cfcuNQvNxhnirfgQdmNMwbjTw0joc22+gjsCgYAmE/Fd+TTiKUF845QyvsEf\nSjY78WbxIM9ey06QKnwkBrsNacrig1NSir+GP6uLXHZ+tr5IrDOIV98ErZ4//KlV\nt/Xjfzu0AhO9lk4BOKMRlHUVBWm3pQIkpzOOmvNKCj6XGDtdJlnHeAkhbhnrypxp\nU8UL/JqG1OVoMRNazP422QKBgHfCS+xKO6622KmH5AFB/HgdlJQi7KKWOiv45mi/\nzrh+kxreFY2hCa0/4XYCpEGjFRqLc6+Gzuz/gxzzBxU0+BEydQBeyy4d5HKWdeTt\nqfr9SMdzhWwDf8NayNPS1gDCEJzcX/uOUtEUNGxfmS4zOMtGKI1Ykxy+jlNcym+6\nVdKDAoGAFSzeX5do66+SyrsjJYDwP04XHltwW19dNgzi3CkhcnJ1PyGjFF33LiLB\npM95wWvTg4JNOrzAsfYqsV+mLaaPMoySrOOCR2TWdKGF1ZpDcUa/zwMqHr4BXMcN\nIcBeMrnMyJDzn5NFIYpHFlQz7E4RYC94vS5eV9oiaY5xWKoyY2I=\n-----END RSA PRIVATE KEY-----\n	-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqUtQDFV2y9xOfymvlABS\niFhoEwX8fJ66h9jRKIcRQuIYNOOcPyXCXCJNbB7K/0I+A3ye05uPNDntcCkHYPDB\nrhvblM/mKJuq8rcLuGkrGMsBJJw77cGm++EEKlv7pvrYv6dJwkLVyzI+iHk9RtbN\nQfsQi4O09Zg3AG91FrkXyBRBxHkUZ+f0wGjVa8R9KJrjVzP5cuIO6y2ZTrwz6D0Q\nhYJAB9yR6PjwLE3MUsoOTuE9bKx9sbl5rsBtgXso96n9hLn9NooOctsKRy88BKc2\nWa5hZfAxdsPoqGRMZNHzGhNvXBHfmcIqv5al3fMuaSkQYDymBKw2Xie29dAMRFfM\nzQIDAQAB\n-----END PUBLIC KEY-----\n				2019-08-12 09:51:55.915485	2019-08-12 09:57:04.485827	I'm definitely not imaginary.	Chad G. Singer		\N	29b645643d075f39.jpg	image/jpeg	27739	2019-08-12 09:57:04.428619	d4f715afe7766c8d.png	image/png	2497	2019-08-12 09:57:04.450642	\N	\N	f		\N					0	8	f	\N	\N	[]	Person	t	\N	f	\N	\N	\N	f	f	f
tomatoguts	\N		-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEAr5Cgacs9KPsUTUJCyI/wMkXhEKt2BvTUUGeGhCBmnqElD9ia\nxRZeT3hZrvUkkh/N2vlYMbk8aSQFJ/D+2e5jeJGeJUKH9lhQtJ4w1RIncVW60ex4\n8LzH+1x7iJXoCmiugnocn3eYdLdkldt3SnDjV+2N/F8vuZaYnIV4eMJxNLcE6mFu\nv5t0sV9kCOVZ1wKd5y6WSRp4vbBZVKPT2RtRyHP/eTVwYCJJ943v7EgDNeQN9fB7\nJEUunj2pW8Bwr3HkzTxiAkUcCacSnDw2qeguivtM/bZURmfsPXxtyI5Efp7ovdBz\nRHJqYSwxGdYWPRRhRNuJddJolNAd5Xae83yIhQIDAQABAoIBAFS9mUAXUmkCb/Uu\no2+NUmHhqtXR/QE0kXpRzfLedMnifDIe2e2Bc3omXBt/xewmH8WvDuvJPih9s2Np\nBooIb8jVeKEBcQDt9d6IcIeX4KPqvmbvHh0M8fYY2KO/v6Wui3T9He2220aS8qEG\nspiizok1Z5BGHZIV54m9Pr4DFINdeujBNqj0JNCTr8J5pSHNfJybQYggLzmbSvCJ\nCNbI1cDSJcUiRFkqOEXfCRoYIwCWSrQ1mtW5Q4RqNRbqzBPJHq+2CDqKnSQI3Mqo\nu+QxWVsFgRuOBmth0o4Ytqwf+UVGTnq0VtjEMdEzRNzQSWpVwwjaGgm8l/jT0nib\nV8cNdi0CgYEA2ndsUt2uuMLLaHyr8nDDV5PVUMojZvb8GSZS9tYXd6jtQ3IW3e+U\nyFcFT1dR/8d8XeWFD8vvEfmi9FZp/JzKdx0gz+ptNsrAXqr152QuLR1uSzO9BO3g\naZ0DLPduZ18QuDKb21F8Z9nmHLkmpMGMnU1XBRXfXaIxcbFGsaD1stMCgYEAzbpP\nkSmIE9rDRjgF+Bp4GV6GpZIdcVZ8JZsCu3Xe89pdrMMyNZp+Q5hNAfpUZBooDTVY\nOQmXrYwkWHp/kKCwfRTySirrXHzy4k1PWlwwtvJfB9mZmsJr/sVykgWBB+6narsk\nAcUVHSqw9f0NsLsfSthHPTtwBb+tXecEARTyUEcCgYAUKuYjGDfi8oiYkrnE3cgK\ns6kDlkWCYdaP88vA4a606zFMAqI9xrozbGUfF+6H8EB44pFQDgF55VO3vqp2GXtP\nV68JwphmcH0lwB6HR+ZDX+4onxQZ+mO3HDmI0yasAEio2HMu4ezcIW9uw2Df4MY8\nV0FrRMOj/y8VUco256cG5QKBgQCBgc+k6ignl4dmJM5dKQyBq+fHQvwV5QOyCKrn\np4P6rnRZ1Wc+J0tk8fNIU3XcrjqYVgR7o3ZAYgBfUn4LZZy0oQMFfY88YcvkehaC\nI5bnFByOrITtz4Z8k39UPPLFM49guP4pvw9TlRRhRjPgFWvVieEOwuP6OnfArTTw\nGWeQ8QKBgQCLSuamuOtDO/XQJvRkySKW0G4kN5tPt5CB17CwOYXd8e2nFL1U+yjB\nYqirXYVH7BEfby5/dfgAGtm/bSFy9PmEyozu/Jshmw7R2AQbnts1yvGomhGHrVW5\nzOv/HLu3luPemg0sb6Ay0gllW+oebcCvFofQcq+U/BHJG70IJpxGXg==\n-----END RSA PRIVATE KEY-----\n	-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAr5Cgacs9KPsUTUJCyI/w\nMkXhEKt2BvTUUGeGhCBmnqElD9iaxRZeT3hZrvUkkh/N2vlYMbk8aSQFJ/D+2e5j\neJGeJUKH9lhQtJ4w1RIncVW60ex48LzH+1x7iJXoCmiugnocn3eYdLdkldt3SnDj\nV+2N/F8vuZaYnIV4eMJxNLcE6mFuv5t0sV9kCOVZ1wKd5y6WSRp4vbBZVKPT2RtR\nyHP/eTVwYCJJ943v7EgDNeQN9fB7JEUunj2pW8Bwr3HkzTxiAkUcCacSnDw2qegu\nivtM/bZURmfsPXxtyI5Efp7ovdBzRHJqYSwxGdYWPRRhRNuJddJolNAd5Xae83yI\nhQIDAQAB\n-----END PUBLIC KEY-----\n				2019-08-12 08:34:58.018228	2019-08-12 10:18:28.487384	Take a tomato, put it in your hand.\r\nSqueeze as hard as you can.\r\nThere you go.			\N	031871b4e671271e.png	image/png	4718	2019-08-12 09:21:41.258319	2d09175022b7bd47.jpg	image/jpeg	22446	2019-08-12 09:21:41.273299	\N	\N	f		\N					0	6	f	\N	\N	[]	Person	t	\N	f	\N	\N	\N	t	f	t
\.


--
-- Data for Name: accounts_tags; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.accounts_tags (account_id, tag_id) FROM stdin;
\.


--
-- Data for Name: admin_action_logs; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.admin_action_logs (id, account_id, action, target_type, target_id, recorded_changes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: ar_internal_metadata; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.ar_internal_metadata (key, value, created_at, updated_at) FROM stdin;
environment	development	2019-08-12 06:17:14.738169	2019-08-12 06:17:14.738169
\.


--
-- Data for Name: backups; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.backups (id, user_id, dump_file_name, dump_content_type, dump_file_size, dump_updated_at, processed, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: blocks; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.blocks (created_at, updated_at, account_id, id, target_account_id, uri) FROM stdin;
\.


--
-- Data for Name: btc_payments; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.btc_payments (id, created_at, updated_at, account_id, btcpay_invoice_id, plan, success) FROM stdin;
\.


--
-- Data for Name: conversation_mutes; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.conversation_mutes (conversation_id, account_id, id) FROM stdin;
\.


--
-- Data for Name: conversations; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.conversations (id, uri, created_at, updated_at) FROM stdin;
1	\N	2019-08-12 09:22:24.674858	2019-08-12 09:22:24.674858
2	\N	2019-08-12 09:57:45.877241	2019-08-12 09:57:45.877241
3	\N	2019-08-12 09:58:40.001002	2019-08-12 09:58:40.001002
\.


--
-- Data for Name: custom_emojis; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.custom_emojis (id, shortcode, domain, image_file_name, image_content_type, image_file_size, image_updated_at, created_at, updated_at, disabled, uri, image_remote_url, visible_in_picker) FROM stdin;
\.


--
-- Data for Name: custom_filters; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.custom_filters (id, account_id, expires_at, phrase, context, irreversible, created_at, updated_at, whole_word) FROM stdin;
\.


--
-- Data for Name: deprecated_preview_cards; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.deprecated_preview_cards (status_id, url, title, description, image_file_name, image_content_type, image_file_size, image_updated_at, created_at, updated_at, type, html, author_name, author_url, provider_name, provider_url, width, height, id) FROM stdin;
\.


--
-- Data for Name: domain_blocks; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.domain_blocks (domain, created_at, updated_at, severity, reject_media, id, reject_reports) FROM stdin;
\.


--
-- Data for Name: email_domain_blocks; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.email_domain_blocks (id, domain, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: favourites; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.favourites (created_at, updated_at, account_id, id, status_id) FROM stdin;
\.


--
-- Data for Name: featured_tags; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.featured_tags (id, account_id, tag_id, statuses_count, last_status_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: follow_requests; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.follow_requests (created_at, updated_at, account_id, id, target_account_id, show_reblogs, uri) FROM stdin;
\.


--
-- Data for Name: follows; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.follows (created_at, updated_at, account_id, id, target_account_id, show_reblogs, uri) FROM stdin;
2019-08-12 09:54:18.921401	2019-08-12 09:54:18.921401	8	1	6	t	https://gab.protohype.net/07ae9b19-bebb-472d-afa0-2f642ad48253
\.


--
-- Data for Name: group_accounts; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.group_accounts (id, group_id, account_id, write_permissions, role, created_at, updated_at, unread_count) FROM stdin;
\.


--
-- Data for Name: group_removed_accounts; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.group_removed_accounts (id, group_id, account_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.groups (id, account_id, title, description, cover_image_file_name, cover_image_content_type, cover_image_file_size, cover_image_updated_at, is_nsfw, is_featured, is_archived, created_at, updated_at, member_count) FROM stdin;
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.identities (provider, uid, created_at, updated_at, id, user_id) FROM stdin;
\.


--
-- Data for Name: imports; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.imports (type, approved, created_at, updated_at, data_file_name, data_content_type, data_file_size, data_updated_at, account_id, id, overwrite) FROM stdin;
\.


--
-- Data for Name: invites; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.invites (id, user_id, code, expires_at, max_uses, uses, created_at, updated_at, autofollow) FROM stdin;
1	6	XvunZQ2k	\N	\N	0	2019-08-12 10:13:22.483987	2019-08-12 10:13:22.483987	f
\.


--
-- Data for Name: list_accounts; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.list_accounts (id, list_id, account_id, follow_id) FROM stdin;
\.


--
-- Data for Name: lists; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.lists (id, account_id, title, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: media_attachments; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.media_attachments (status_id, file_file_name, file_content_type, file_file_size, file_updated_at, remote_url, created_at, updated_at, shortcode, type, file_meta, account_id, id, description, scheduled_status_id, blurhash) FROM stdin;
\.


--
-- Data for Name: mentions; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.mentions (status_id, created_at, updated_at, account_id, id, silent) FROM stdin;
102603418498738230	2019-08-12 09:58:40.023061	2019-08-12 09:58:40.023061	6	1	f
\.


--
-- Data for Name: mutes; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.mutes (created_at, updated_at, hide_notifications, account_id, id, target_account_id) FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.notifications (activity_id, activity_type, created_at, updated_at, account_id, from_account_id, id) FROM stdin;
1	Follow	2019-08-12 09:54:18.971209	2019-08-12 09:54:18.971209	6	8	1
1	Mention	2019-08-12 09:58:40.097714	2019-08-12 09:58:40.097714	6	8	2
\.


--
-- Data for Name: oauth_access_grants; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.oauth_access_grants (token, expires_in, redirect_uri, created_at, revoked_at, scopes, application_id, id, resource_owner_id) FROM stdin;
\.


--
-- Data for Name: oauth_access_tokens; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.oauth_access_tokens (token, refresh_token, expires_in, revoked_at, created_at, scopes, application_id, id, resource_owner_id) FROM stdin;
\.


--
-- Data for Name: oauth_applications; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.oauth_applications (name, uid, secret, redirect_uri, scopes, created_at, updated_at, superapp, website, owner_type, id, owner_id, confidential) FROM stdin;
\.


--
-- Data for Name: pghero_space_stats; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.pghero_space_stats (id, database, schema, relation, size, captured_at) FROM stdin;
\.


--
-- Data for Name: poll_votes; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.poll_votes (id, account_id, poll_id, choice, created_at, updated_at, uri) FROM stdin;
\.


--
-- Data for Name: polls; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.polls (id, account_id, status_id, expires_at, options, cached_tallies, multiple, hide_totals, votes_count, last_fetched_at, created_at, updated_at, lock_version) FROM stdin;
\.


--
-- Data for Name: preview_cards; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.preview_cards (id, url, title, description, image_file_name, image_content_type, image_file_size, image_updated_at, type, html, author_name, author_url, provider_name, provider_url, width, height, created_at, updated_at, embed_url) FROM stdin;
\.


--
-- Data for Name: preview_cards_statuses; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.preview_cards_statuses (preview_card_id, status_id) FROM stdin;
\.


--
-- Data for Name: relays; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.relays (id, inbox_url, follow_activity_id, created_at, updated_at, state) FROM stdin;
\.


--
-- Data for Name: report_notes; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.report_notes (id, content, report_id, account_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: reports; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.reports (status_ids, comment, action_taken, created_at, updated_at, account_id, action_taken_by_account_id, id, target_account_id, assigned_account_id, uri) FROM stdin;
\.


--
-- Data for Name: scheduled_statuses; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.scheduled_statuses (id, account_id, scheduled_at, params) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.schema_migrations (version) FROM stdin;
0
20160220174730
20160220211917
20160221003140
20160221003621
20160222122600
20160222143943
20160223162837
20160223164502
20160223165723
20160223165855
20160223171800
20160224223247
20160227230233
20160305115639
20160306172223
20160312193225
20160314164231
20160316103650
20160322193748
20160325130944
20160826155805
20160905150353
20160919221059
20160920003904
20160926213048
20161003142332
20161003145426
20161006213403
20161009120834
20161027172456
20161104173623
20161105130633
20161116162355
20161119211120
20161122163057
20161123093447
20161128103007
20161130142058
20161130185319
20161202132159
20161203164520
20161205214545
20161221152630
20161222201034
20161222204147
20170105224407
20170109120109
20170112154826
20170114194937
20170114203041
20170119214911
20170123162658
20170123203248
20170125145934
20170127165745
20170129000348
20170205175257
20170209184350
20170214110202
20170217012631
20170301222600
20170303212857
20170304202101
20170317193015
20170318214217
20170322021028
20170322143850
20170322162804
20170330021336
20170330163835
20170330164118
20170403172249
20170405112956
20170406215816
20170409170753
20170414080609
20170414132105
20170418160728
20170423005413
20170424003227
20170424112722
20170425131920
20170425202925
20170427011934
20170506235850
20170507000211
20170507141759
20170508230434
20170516072309
20170520145338
20170601210557
20170604144747
20170606113804
20170609145826
20170610000000
20170623152212
20170624134742
20170625140443
20170711225116
20170713112503
20170713175513
20170713190709
20170714184731
20170716191202
20170718211102
20170720000000
20170823162448
20170824103029
20170829215220
20170901141119
20170901142658
20170905044538
20170905165803
20170913000752
20170917153509
20170918125918
20170920024819
20170920032311
20170924022025
20170927215609
20170928082043
20171005102658
20171005171936
20171006142024
20171010023049
20171010025614
20171020084748
20171028221157
20171107143332
20171107143624
20171109012327
20171114080328
20171114231651
20171116161857
20171118012443
20171119172437
20171122120436
20171125024930
20171125031751
20171125185353
20171125190735
20171129172043
20171130000000
20171201000000
20171212195226
20171226094803
20180106000232
20180109143959
20180204034416
20180206000000
20180211015820
20180304013859
20180310000000
20180402031200
20180402040909
20180410204633
20180416210259
20180506221944
20180510214435
20180510230049
20180514130000
20180514140000
20180528141303
20180608213548
20180609104432
20180615122121
20180616192031
20180617162849
20180628181026
20180707154237
20180711152640
20180808175627
20180812123222
20180812162710
20180812173710
20180813113448
20180814171349
20180820232245
20180929222014
20181007025445
20181010141500
20181017170937
20181018205649
20181024224956
20181026034033
20181116165755
20181116173541
20181116184611
20181127130500
20181203003808
20181203021853
20181204193439
20181204215309
20181207011115
20181213184704
20181213185533
20181219235220
20181226021420
20190103124649
20190103124754
20190117114553
20190201012802
20190203180359
20190225031541
20190225031625
20190226003449
20190304152020
20190306145741
20190307234537
20190314181829
20190316190352
20190317135723
20190409054914
20190420025523
20190509164208
20190510222844
20190510231315
20190511134027
20190511152737
20190512160135
20190512225945
20190514225311
20190515001947
20190519130537
20190526171044
20190529143559
20190603162444
20190603163444
20190607000211
20190716173227
20190721214831
20190721234917
20190722003541
20190722003649
20190804115634
\.


--
-- Data for Name: session_activations; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.session_activations (id, session_id, created_at, updated_at, user_agent, ip, access_token_id, user_id, web_push_subscription_id) FROM stdin;
\.


--
-- Data for Name: settings; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.settings (var, value, thing_type, created_at, updated_at, id, thing_id) FROM stdin;
site_contact_username	--- tomatoguts\n...\n	\N	2019-08-12 10:08:34.633636	2019-08-12 10:08:34.633636	1	\N
site_contact_email	--- csinger@protohype.net\n...\n	\N	2019-08-12 10:08:34.637071	2019-08-12 10:08:34.637071	2	\N
site_title	--- Carnal Gabhub\n...\n	\N	2019-08-12 10:08:34.639787	2019-08-12 10:08:34.639787	3	\N
site_short_description	--- Well, it's like gab.ai, only not.\n...\n	\N	2019-08-12 10:08:34.641893	2019-08-12 10:08:34.641893	4	\N
site_description	--- "Well Frank, here it is! \\r\\n\\r\\nNow someone's gotta come up with a bunch of text\n  to put in all these boxes. \\r\\n\\r\\nPictures too."\n	\N	2019-08-12 10:08:34.643995	2019-08-12 10:08:34.643995	5	\N
site_extended_description	--- ''\n	\N	2019-08-12 10:08:34.646081	2019-08-12 10:08:34.646081	6	\N
site_terms	--- ''\n	\N	2019-08-12 10:08:34.648218	2019-08-12 10:08:34.648218	7	\N
registrations_mode	--- approved\n...\n	\N	2019-08-12 10:08:34.650345	2019-08-12 10:08:34.650345	8	\N
closed_registrations_message	--- ''\n	\N	2019-08-12 10:08:34.652477	2019-08-12 10:08:34.652477	9	\N
open_deletion	--- true\n...\n	\N	2019-08-12 10:08:34.654579	2019-08-12 10:08:34.654579	10	\N
timeline_preview	--- true\n...\n	\N	2019-08-12 10:08:34.656691	2019-08-12 10:08:34.656691	11	\N
show_staff_badge	--- true\n...\n	\N	2019-08-12 10:08:34.658826	2019-08-12 10:08:34.658826	12	\N
theme	--- default\n...\n	\N	2019-08-12 10:08:34.663082	2019-08-12 10:08:34.663082	14	\N
min_invite_role	--- admin\n...\n	\N	2019-08-12 10:08:34.665207	2019-08-12 10:08:34.665207	15	\N
activity_api_enabled	--- true\n...\n	\N	2019-08-12 10:08:34.667282	2019-08-12 10:08:34.667282	16	\N
peers_api_enabled	--- true\n...\n	\N	2019-08-12 10:08:34.669414	2019-08-12 10:08:34.669414	17	\N
show_known_fediverse_at_about_page	--- true\n...\n	\N	2019-08-12 10:08:34.671524	2019-08-12 10:08:34.671524	18	\N
preview_sensitive_media	--- false\n...\n	\N	2019-08-12 10:08:34.673636	2019-08-12 10:08:34.673636	19	\N
custom_css	--- ''\n	\N	2019-08-12 10:08:34.67576	2019-08-12 10:08:34.67576	20	\N
profile_directory	--- true\n...\n	\N	2019-08-12 10:08:34.678089	2019-08-12 10:08:34.678089	21	\N
bootstrap_timeline_accounts	--- tomatoguts\n...\n	\N	2019-08-12 10:08:34.660949	2019-08-12 10:09:33.131345	13	\N
thumbnail	--- \n...\n	\N	2019-08-12 10:09:33.144649	2019-08-12 10:09:33.144649	22	\N
hero	--- \n...\n	\N	2019-08-12 10:09:33.147138	2019-08-12 10:09:33.147138	23	\N
mascot	--- \n...\n	\N	2019-08-12 10:09:33.149557	2019-08-12 10:09:33.149557	24	\N
default_privacy	--- public\n...\n	User	2019-08-12 10:17:55.275285	2019-08-12 10:17:55.275285	25	6
default_sensitive	--- false\n...\n	User	2019-08-12 10:17:55.279353	2019-08-12 10:17:55.279353	26	6
default_language	--- ''\n	User	2019-08-12 10:17:55.282467	2019-08-12 10:17:55.282467	27	6
unfollow_modal	--- false\n...\n	User	2019-08-12 10:17:55.285429	2019-08-12 10:17:55.285429	28	6
boost_modal	--- false\n...\n	User	2019-08-12 10:17:55.288304	2019-08-12 10:17:55.288304	29	6
delete_modal	--- true\n...\n	User	2019-08-12 10:17:55.291157	2019-08-12 10:17:55.291157	30	6
auto_play_gif	--- true\n...\n	User	2019-08-12 10:17:55.293919	2019-08-12 10:17:55.293919	31	6
display_media	--- default\n...\n	User	2019-08-12 10:17:55.29682	2019-08-12 10:17:55.29682	32	6
expand_spoilers	--- false\n...\n	User	2019-08-12 10:17:55.299515	2019-08-12 10:17:55.299515	33	6
reduce_motion	--- false\n...\n	User	2019-08-12 10:17:55.302314	2019-08-12 10:17:55.302314	34	6
system_font_ui	--- false\n...\n	User	2019-08-12 10:17:55.305039	2019-08-12 10:17:55.305039	35	6
noindex	--- false\n...\n	User	2019-08-12 10:17:55.307816	2019-08-12 10:17:55.307816	36	6
theme	--- default\n...\n	User	2019-08-12 10:17:55.310589	2019-08-12 10:17:55.310589	37	6
hide_network	--- false\n...\n	User	2019-08-12 10:17:55.313334	2019-08-12 10:17:55.313334	38	6
aggregate_reblogs	--- true\n...\n	User	2019-08-12 10:17:55.316139	2019-08-12 10:17:55.316139	39	6
show_application	--- true\n...\n	User	2019-08-12 10:17:55.318874	2019-08-12 10:17:55.318874	40	6
advanced_layout	--- true\n...\n	User	2019-08-12 10:17:55.321715	2019-08-12 10:17:55.321715	41	6
group_in_home_feed	--- true\n...\n	User	2019-08-12 10:17:55.324546	2019-08-12 10:17:55.324546	42	6
notification_emails	---\nfollow: false\nreblog: false\nfavourite: false\nmention: false\nfollow_request: true\ndigest: true\nreport: true\npending_account: true\nemails_from_gabcom: true\n	User	2019-08-12 10:18:03.917796	2019-08-12 10:18:03.917796	43	6
interactions	---\nmust_be_follower: false\nmust_be_following: false\nmust_be_following_dm: false\n	User	2019-08-12 10:18:03.921805	2019-08-12 10:18:03.921805	44	6
\.


--
-- Data for Name: site_uploads; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.site_uploads (id, var, file_file_name, file_content_type, file_file_size, file_updated_at, meta, created_at, updated_at) FROM stdin;
1	thumbnail	IMG_20190614_135330.jpg	image/jpeg	3185171	2019-08-12 10:08:34.686824	{"width":4048,"height":3036}	2019-08-12 10:08:34.696685	2019-08-12 10:08:34.696685
2	hero	profpic.jpg	image/jpeg	1935344	2019-08-12 10:08:34.702688	{"width":1664,"height":1760}	2019-08-12 10:08:34.7114	2019-08-12 10:08:34.7114
3	mascot	IMG_20190625_185426.jpg	image/jpeg	4884622	2019-08-12 10:08:34.715993	{"width":4048,"height":3036}	2019-08-12 10:08:34.736297	2019-08-12 10:08:34.736297
\.


--
-- Data for Name: status_pins; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.status_pins (id, account_id, status_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: status_stats; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.status_stats (id, status_id, replies_count, reblogs_count, favourites_count, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: statuses; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.statuses (id, uri, text, created_at, updated_at, in_reply_to_id, reblog_of_id, url, sensitive, visibility, spoiler_text, reply, language, conversation_id, local, account_id, application_id, in_reply_to_account_id, poll_id, group_id, quote_of_id) FROM stdin;
102603275937430041	https://gab.protohype.net/users/tomatoguts/statuses/102603275937430041	First.	2019-08-12 09:22:24.675824	2019-08-12 09:22:24.675824	\N	\N	\N	f	0		f	en	1	t	6	\N	\N	\N	\N	\N
102603414953665508	https://gab.protohype.net/users/csinger/statuses/102603414953665508	Second	2019-08-12 09:57:45.878202	2019-08-12 09:57:45.878202	\N	\N	\N	f	0		f	en	2	t	8	\N	\N	\N	\N	\N
102603418498738230	https://gab.protohype.net/users/csinger/statuses/102603418498738230	Hey @tomatoguts \nHas anyone ever told you that you're an uncharismatic boor?\nSomeone should do that.	2019-08-12 09:58:40.002096	2019-08-12 09:58:40.002096	\N	\N	\N	f	0		f	en	3	t	8	\N	\N	\N	\N	\N
\.


--
-- Data for Name: statuses_tags; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.statuses_tags (status_id, tag_id) FROM stdin;
\.


--
-- Data for Name: stream_entries; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.stream_entries (activity_id, activity_type, created_at, updated_at, hidden, account_id, id) FROM stdin;
102603275937430041	Status	2019-08-12 09:22:24.689455	2019-08-12 09:22:24.689455	f	6	1
102603414953665508	Status	2019-08-12 09:57:45.883266	2019-08-12 09:57:45.883266	f	8	2
102603418498738230	Status	2019-08-12 09:58:40.00688	2019-08-12 09:58:40.00688	f	8	3
\.


--
-- Data for Name: subscriptions; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.subscriptions (callback_url, secret, expires_at, confirmed, created_at, updated_at, last_successful_delivery_at, domain, account_id, id) FROM stdin;
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.tags (name, created_at, updated_at, id) FROM stdin;
\.


--
-- Data for Name: tombstones; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.tombstones (id, account_id, uri, created_at, updated_at, by_moderator) FROM stdin;
\.


--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.transactions (id, created_at, updated_at, account_id, payment_type, provider_type, provider_response, amount, success) FROM stdin;
\.


--
-- Data for Name: user_invite_requests; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.user_invite_requests (id, user_id, text, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.users (email, created_at, updated_at, encrypted_password, reset_password_token, reset_password_sent_at, remember_created_at, sign_in_count, current_sign_in_at, last_sign_in_at, current_sign_in_ip, last_sign_in_ip, admin, confirmation_token, confirmed_at, confirmation_sent_at, unconfirmed_email, locale, encrypted_otp_secret, encrypted_otp_secret_iv, encrypted_otp_secret_salt, consumed_timestep, otp_required_for_login, last_emailed_at, otp_backup_codes, filtered_languages, account_id, id, disabled, moderator, invite_id, remember_token, chosen_languages, created_by_application_id, approved) FROM stdin;
csinger@fusionconnect.com	2019-08-12 09:30:36.989525	2019-08-12 09:30:36.989525	$2a$10$uBUh6bdrtia0nlsHxKxpE.So1B10tiR4kJNNZyendOEIQRYdmkwku	\N	\N	\N	0	\N	\N	24.125.156.154	\N	f	pT7hdC8Tq1czs1mvZXrU	\N	2019-08-12 09:30:36.989662	\N	en	\N	\N	\N	\N	f	\N	\N	{}	7	7	f	f	\N	\N	\N	\N	t
purchasing@protohype.net	2019-08-12 09:51:56.009157	2019-08-12 10:02:58.67705	$2a$10$RqFIMh4aKpgKFJGVoWPceeO9WOJ3dsIh8S2..kbzmFTaT95dXwtkq	\N	\N	\N	2	2019-08-12 09:57:38.694794	2019-08-12 09:54:29.442856	24.125.156.154	24.125.156.154	f	kx7sjiL5d-jYXjYp6xXQ	2019-08-12 09:54:18.593433	2019-08-12 09:51:56.009294	\N	en	\N	\N	\N	\N	f	\N	\N	{}	8	8	f	f	\N	\N	\N	\N	t
csinger@protohype.net	2019-08-12 08:34:58.267445	2019-08-12 10:49:30.758898	$2a$10$vRakEQyB8yEl/jzDdHTK5eoY.NSY8vcbLj4t.MO6sdVdazWLpnedK	\N	\N	\N	3	2019-08-12 10:12:20.209758	2019-08-12 10:03:05.362213	24.125.156.154	24.125.156.154	t	QVUDR8u8942tboEKM7b9	2019-08-12 09:07:36.23839	2019-08-12 08:34:58.267614	\N	en	\N	\N	\N	\N	f	\N	\N	{}	6	6	f	f	\N	\N	\N	\N	t
\.


--
-- Data for Name: web_push_subscriptions; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.web_push_subscriptions (id, endpoint, key_p256dh, key_auth, data, created_at, updated_at, access_token_id, user_id) FROM stdin;
\.


--
-- Data for Name: web_settings; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.web_settings (data, created_at, updated_at, id, user_id) FROM stdin;
\.


--
-- Name: account_conversations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.account_conversations_id_seq', 1, false);


--
-- Name: account_domain_blocks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.account_domain_blocks_id_seq', 1, false);


--
-- Name: account_identity_proofs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.account_identity_proofs_id_seq', 1, false);


--
-- Name: account_moderation_notes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.account_moderation_notes_id_seq', 1, false);


--
-- Name: account_pins_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.account_pins_id_seq', 1, false);


--
-- Name: account_stats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.account_stats_id_seq', 8, true);


--
-- Name: account_tag_stats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.account_tag_stats_id_seq', 1, false);


--
-- Name: account_verification_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.account_verification_requests_id_seq', 1, false);


--
-- Name: account_warning_presets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.account_warning_presets_id_seq', 1, false);


--
-- Name: account_warnings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.account_warnings_id_seq', 1, false);


--
-- Name: accounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.accounts_id_seq', 8, true);


--
-- Name: admin_action_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.admin_action_logs_id_seq', 1, false);


--
-- Name: backups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.backups_id_seq', 1, false);


--
-- Name: blocks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.blocks_id_seq', 1, false);


--
-- Name: btc_payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.btc_payments_id_seq', 1, false);


--
-- Name: conversation_mutes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.conversation_mutes_id_seq', 1, false);


--
-- Name: conversations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.conversations_id_seq', 3, true);


--
-- Name: custom_emojis_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.custom_emojis_id_seq', 1, false);


--
-- Name: custom_filters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.custom_filters_id_seq', 1, false);


--
-- Name: deprecated_preview_cards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.deprecated_preview_cards_id_seq', 1, false);


--
-- Name: domain_blocks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.domain_blocks_id_seq', 1, false);


--
-- Name: email_domain_blocks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.email_domain_blocks_id_seq', 1, false);


--
-- Name: favourites_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.favourites_id_seq', 1, false);


--
-- Name: featured_tags_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.featured_tags_id_seq', 1, false);


--
-- Name: follow_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.follow_requests_id_seq', 1, false);


--
-- Name: follows_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.follows_id_seq', 1, true);


--
-- Name: group_accounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.group_accounts_id_seq', 1, false);


--
-- Name: group_removed_accounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.group_removed_accounts_id_seq', 1, false);


--
-- Name: groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.groups_id_seq', 1, false);


--
-- Name: identities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.identities_id_seq', 1, false);


--
-- Name: imports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.imports_id_seq', 1, false);


--
-- Name: invites_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.invites_id_seq', 1, true);


--
-- Name: list_accounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.list_accounts_id_seq', 1, false);


--
-- Name: lists_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.lists_id_seq', 1, false);


--
-- Name: media_attachments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.media_attachments_id_seq', 1, false);


--
-- Name: mentions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.mentions_id_seq', 1, true);


--
-- Name: mutes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.mutes_id_seq', 1, false);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.notifications_id_seq', 2, true);


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.oauth_access_grants_id_seq', 1, false);


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.oauth_access_tokens_id_seq', 5, true);


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.oauth_applications_id_seq', 1, false);


--
-- Name: pghero_space_stats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.pghero_space_stats_id_seq', 1, false);


--
-- Name: poll_votes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.poll_votes_id_seq', 1, false);


--
-- Name: polls_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.polls_id_seq', 1, false);


--
-- Name: preview_cards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.preview_cards_id_seq', 1, false);


--
-- Name: relays_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.relays_id_seq', 1, false);


--
-- Name: report_notes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.report_notes_id_seq', 1, false);


--
-- Name: reports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.reports_id_seq', 1, false);


--
-- Name: scheduled_statuses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.scheduled_statuses_id_seq', 1, false);


--
-- Name: session_activations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.session_activations_id_seq', 5, true);


--
-- Name: settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.settings_id_seq', 44, true);


--
-- Name: site_uploads_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.site_uploads_id_seq', 3, true);


--
-- Name: status_pins_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.status_pins_id_seq', 1, false);


--
-- Name: status_stats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.status_stats_id_seq', 1, false);


--
-- Name: statuses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.statuses_id_seq', 3, true);


--
-- Name: stream_entries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.stream_entries_id_seq', 3, true);


--
-- Name: subscriptions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.subscriptions_id_seq', 1, false);


--
-- Name: tags_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.tags_id_seq', 1, false);


--
-- Name: tombstones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.tombstones_id_seq', 1, false);


--
-- Name: transactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.transactions_id_seq', 1, false);


--
-- Name: user_invite_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.user_invite_requests_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.users_id_seq', 8, true);


--
-- Name: web_push_subscriptions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.web_push_subscriptions_id_seq', 1, false);


--
-- Name: web_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.web_settings_id_seq', 1, false);


--
-- Name: account_conversations account_conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_conversations
    ADD CONSTRAINT account_conversations_pkey PRIMARY KEY (id);


--
-- Name: account_identity_proofs account_identity_proofs_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_identity_proofs
    ADD CONSTRAINT account_identity_proofs_pkey PRIMARY KEY (id);


--
-- Name: account_moderation_notes account_moderation_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_moderation_notes
    ADD CONSTRAINT account_moderation_notes_pkey PRIMARY KEY (id);


--
-- Name: account_pins account_pins_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_pins
    ADD CONSTRAINT account_pins_pkey PRIMARY KEY (id);


--
-- Name: account_stats account_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_stats
    ADD CONSTRAINT account_stats_pkey PRIMARY KEY (id);


--
-- Name: account_tag_stats account_tag_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_tag_stats
    ADD CONSTRAINT account_tag_stats_pkey PRIMARY KEY (id);


--
-- Name: account_verification_requests account_verification_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_verification_requests
    ADD CONSTRAINT account_verification_requests_pkey PRIMARY KEY (id);


--
-- Name: account_warning_presets account_warning_presets_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_warning_presets
    ADD CONSTRAINT account_warning_presets_pkey PRIMARY KEY (id);


--
-- Name: account_warnings account_warnings_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_warnings
    ADD CONSTRAINT account_warnings_pkey PRIMARY KEY (id);


--
-- Name: admin_action_logs admin_action_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.admin_action_logs
    ADD CONSTRAINT admin_action_logs_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: backups backups_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.backups
    ADD CONSTRAINT backups_pkey PRIMARY KEY (id);


--
-- Name: btc_payments btc_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.btc_payments
    ADD CONSTRAINT btc_payments_pkey PRIMARY KEY (id);


--
-- Name: conversations conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_pkey PRIMARY KEY (id);


--
-- Name: custom_emojis custom_emojis_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.custom_emojis
    ADD CONSTRAINT custom_emojis_pkey PRIMARY KEY (id);


--
-- Name: custom_filters custom_filters_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.custom_filters
    ADD CONSTRAINT custom_filters_pkey PRIMARY KEY (id);


--
-- Name: email_domain_blocks email_domain_blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.email_domain_blocks
    ADD CONSTRAINT email_domain_blocks_pkey PRIMARY KEY (id);


--
-- Name: featured_tags featured_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.featured_tags
    ADD CONSTRAINT featured_tags_pkey PRIMARY KEY (id);


--
-- Name: group_accounts group_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.group_accounts
    ADD CONSTRAINT group_accounts_pkey PRIMARY KEY (id);


--
-- Name: group_removed_accounts group_removed_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.group_removed_accounts
    ADD CONSTRAINT group_removed_accounts_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: account_domain_blocks index_account_domain_blocks_on_id; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_domain_blocks
    ADD CONSTRAINT index_account_domain_blocks_on_id PRIMARY KEY (id);


--
-- Name: accounts index_accounts_on_id; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT index_accounts_on_id PRIMARY KEY (id);


--
-- Name: blocks index_blocks_on_id; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT index_blocks_on_id PRIMARY KEY (id);


--
-- Name: conversation_mutes index_conversation_mutes_on_id; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.conversation_mutes
    ADD CONSTRAINT index_conversation_mutes_on_id PRIMARY KEY (id);


--
-- Name: deprecated_preview_cards index_deprecated_preview_cards_on_id; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.deprecated_preview_cards
    ADD CONSTRAINT index_deprecated_preview_cards_on_id PRIMARY KEY (id);


--
-- Name: domain_blocks index_domain_blocks_on_id; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.domain_blocks
    ADD CONSTRAINT index_domain_blocks_on_id PRIMARY KEY (id);


--
-- Name: favourites index_favourites_on_id; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.favourites
    ADD CONSTRAINT index_favourites_on_id PRIMARY KEY (id);


--
-- Name: follow_requests index_follow_requests_on_id; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.follow_requests
    ADD CONSTRAINT index_follow_requests_on_id PRIMARY KEY (id);


--
-- Name: follows index_follows_on_id; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.follows
    ADD CONSTRAINT index_follows_on_id PRIMARY KEY (id);


--
-- Name: identities index_identities_on_id; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.identities
    ADD CONSTRAINT index_identities_on_id PRIMARY KEY (id);


--
-- Name: imports index_imports_on_id; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.imports
    ADD CONSTRAINT index_imports_on_id PRIMARY KEY (id);


--
-- Name: media_attachments index_media_attachments_on_id; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.media_attachments
    ADD CONSTRAINT index_media_attachments_on_id PRIMARY KEY (id);


--
-- Name: mentions index_mentions_on_id; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.mentions
    ADD CONSTRAINT index_mentions_on_id PRIMARY KEY (id);


--
-- Name: mutes index_mutes_on_id; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.mutes
    ADD CONSTRAINT index_mutes_on_id PRIMARY KEY (id);


--
-- Name: notifications index_notifications_on_id; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT index_notifications_on_id PRIMARY KEY (id);


--
-- Name: oauth_access_grants index_oauth_access_grants_on_id; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT index_oauth_access_grants_on_id PRIMARY KEY (id);


--
-- Name: oauth_access_tokens index_oauth_access_tokens_on_id; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT index_oauth_access_tokens_on_id PRIMARY KEY (id);


--
-- Name: oauth_applications index_oauth_applications_on_id; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.oauth_applications
    ADD CONSTRAINT index_oauth_applications_on_id PRIMARY KEY (id);


--
-- Name: reports index_reports_on_id; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT index_reports_on_id PRIMARY KEY (id);


--
-- Name: settings index_settings_on_id; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT index_settings_on_id PRIMARY KEY (id);


--
-- Name: stream_entries index_stream_entries_on_id; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.stream_entries
    ADD CONSTRAINT index_stream_entries_on_id PRIMARY KEY (id);


--
-- Name: subscriptions index_subscriptions_on_id; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT index_subscriptions_on_id PRIMARY KEY (id);


--
-- Name: tags index_tags_on_id; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT index_tags_on_id PRIMARY KEY (id);


--
-- Name: users index_users_on_id; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT index_users_on_id PRIMARY KEY (id);


--
-- Name: web_settings index_web_settings_on_id; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.web_settings
    ADD CONSTRAINT index_web_settings_on_id PRIMARY KEY (id);


--
-- Name: invites invites_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.invites
    ADD CONSTRAINT invites_pkey PRIMARY KEY (id);


--
-- Name: list_accounts list_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.list_accounts
    ADD CONSTRAINT list_accounts_pkey PRIMARY KEY (id);


--
-- Name: lists lists_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.lists
    ADD CONSTRAINT lists_pkey PRIMARY KEY (id);


--
-- Name: pghero_space_stats pghero_space_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.pghero_space_stats
    ADD CONSTRAINT pghero_space_stats_pkey PRIMARY KEY (id);


--
-- Name: poll_votes poll_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.poll_votes
    ADD CONSTRAINT poll_votes_pkey PRIMARY KEY (id);


--
-- Name: polls polls_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.polls
    ADD CONSTRAINT polls_pkey PRIMARY KEY (id);


--
-- Name: preview_cards preview_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.preview_cards
    ADD CONSTRAINT preview_cards_pkey PRIMARY KEY (id);


--
-- Name: relays relays_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.relays
    ADD CONSTRAINT relays_pkey PRIMARY KEY (id);


--
-- Name: report_notes report_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.report_notes
    ADD CONSTRAINT report_notes_pkey PRIMARY KEY (id);


--
-- Name: scheduled_statuses scheduled_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.scheduled_statuses
    ADD CONSTRAINT scheduled_statuses_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: session_activations session_activations_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.session_activations
    ADD CONSTRAINT session_activations_pkey PRIMARY KEY (id);


--
-- Name: site_uploads site_uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.site_uploads
    ADD CONSTRAINT site_uploads_pkey PRIMARY KEY (id);


--
-- Name: status_pins status_pins_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.status_pins
    ADD CONSTRAINT status_pins_pkey PRIMARY KEY (id);


--
-- Name: status_stats status_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.status_stats
    ADD CONSTRAINT status_stats_pkey PRIMARY KEY (id);


--
-- Name: statuses statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.statuses
    ADD CONSTRAINT statuses_pkey PRIMARY KEY (id);


--
-- Name: tombstones tombstones_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.tombstones
    ADD CONSTRAINT tombstones_pkey PRIMARY KEY (id);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: user_invite_requests user_invite_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.user_invite_requests
    ADD CONSTRAINT user_invite_requests_pkey PRIMARY KEY (id);


--
-- Name: web_push_subscriptions web_push_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.web_push_subscriptions
    ADD CONSTRAINT web_push_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: account_activity; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX account_activity ON public.notifications USING btree (account_id, activity_id, activity_type);


--
-- Name: hashtag_search_index; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX hashtag_search_index ON public.tags USING btree (lower((name)::text) text_pattern_ops);


--
-- Name: index_account_conversations_on_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_account_conversations_on_account_id ON public.account_conversations USING btree (account_id);


--
-- Name: index_account_conversations_on_conversation_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_account_conversations_on_conversation_id ON public.account_conversations USING btree (conversation_id);


--
-- Name: index_account_domain_blocks_on_account_id_and_domain; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_account_domain_blocks_on_account_id_and_domain ON public.account_domain_blocks USING btree (account_id, domain);


--
-- Name: index_account_identity_proofs_on_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_account_identity_proofs_on_account_id ON public.account_identity_proofs USING btree (account_id);


--
-- Name: index_account_moderation_notes_on_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_account_moderation_notes_on_account_id ON public.account_moderation_notes USING btree (account_id);


--
-- Name: index_account_moderation_notes_on_target_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_account_moderation_notes_on_target_account_id ON public.account_moderation_notes USING btree (target_account_id);


--
-- Name: index_account_pins_on_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_account_pins_on_account_id ON public.account_pins USING btree (account_id);


--
-- Name: index_account_pins_on_account_id_and_target_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_account_pins_on_account_id_and_target_account_id ON public.account_pins USING btree (account_id, target_account_id);


--
-- Name: index_account_pins_on_target_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_account_pins_on_target_account_id ON public.account_pins USING btree (target_account_id);


--
-- Name: index_account_proofs_on_account_and_provider_and_username; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_account_proofs_on_account_and_provider_and_username ON public.account_identity_proofs USING btree (account_id, provider, provider_username);


--
-- Name: index_account_stats_on_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_account_stats_on_account_id ON public.account_stats USING btree (account_id);


--
-- Name: index_account_tag_stats_on_tag_id; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_account_tag_stats_on_tag_id ON public.account_tag_stats USING btree (tag_id);


--
-- Name: index_account_verification_requests_on_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_account_verification_requests_on_account_id ON public.account_verification_requests USING btree (account_id);


--
-- Name: index_account_warnings_on_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_account_warnings_on_account_id ON public.account_warnings USING btree (account_id);


--
-- Name: index_account_warnings_on_target_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_account_warnings_on_target_account_id ON public.account_warnings USING btree (target_account_id);


--
-- Name: index_accounts_on_moved_to_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_accounts_on_moved_to_account_id ON public.accounts USING btree (moved_to_account_id);


--
-- Name: index_accounts_on_uri; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_accounts_on_uri ON public.accounts USING btree (uri);


--
-- Name: index_accounts_on_url; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_accounts_on_url ON public.accounts USING btree (url);


--
-- Name: index_accounts_on_username_and_domain_lower; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_accounts_on_username_and_domain_lower ON public.accounts USING btree (lower((username)::text), lower((domain)::text));


--
-- Name: index_accounts_tags_on_account_id_and_tag_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_accounts_tags_on_account_id_and_tag_id ON public.accounts_tags USING btree (account_id, tag_id);


--
-- Name: index_accounts_tags_on_tag_id_and_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_accounts_tags_on_tag_id_and_account_id ON public.accounts_tags USING btree (tag_id, account_id);


--
-- Name: index_admin_action_logs_on_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_admin_action_logs_on_account_id ON public.admin_action_logs USING btree (account_id);


--
-- Name: index_admin_action_logs_on_target_type_and_target_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_admin_action_logs_on_target_type_and_target_id ON public.admin_action_logs USING btree (target_type, target_id);


--
-- Name: index_blocks_on_account_id_and_target_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_blocks_on_account_id_and_target_account_id ON public.blocks USING btree (account_id, target_account_id);


--
-- Name: index_blocks_on_target_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_blocks_on_target_account_id ON public.blocks USING btree (target_account_id);


--
-- Name: index_conversation_mutes_on_account_id_and_conversation_id; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_conversation_mutes_on_account_id_and_conversation_id ON public.conversation_mutes USING btree (account_id, conversation_id);


--
-- Name: index_conversations_on_uri; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_conversations_on_uri ON public.conversations USING btree (uri);


--
-- Name: index_custom_emojis_on_shortcode_and_domain; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_custom_emojis_on_shortcode_and_domain ON public.custom_emojis USING btree (shortcode, domain);


--
-- Name: index_custom_filters_on_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_custom_filters_on_account_id ON public.custom_filters USING btree (account_id);


--
-- Name: index_deprecated_preview_cards_on_status_id; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_deprecated_preview_cards_on_status_id ON public.deprecated_preview_cards USING btree (status_id);


--
-- Name: index_domain_blocks_on_domain; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_domain_blocks_on_domain ON public.domain_blocks USING btree (domain);


--
-- Name: index_email_domain_blocks_on_domain; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_email_domain_blocks_on_domain ON public.email_domain_blocks USING btree (domain);


--
-- Name: index_favourites_on_account_id_and_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_favourites_on_account_id_and_id ON public.favourites USING btree (account_id, id);


--
-- Name: index_favourites_on_account_id_and_status_id; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_favourites_on_account_id_and_status_id ON public.favourites USING btree (account_id, status_id);


--
-- Name: index_favourites_on_status_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_favourites_on_status_id ON public.favourites USING btree (status_id);


--
-- Name: index_featured_tags_on_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_featured_tags_on_account_id ON public.featured_tags USING btree (account_id);


--
-- Name: index_featured_tags_on_tag_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_featured_tags_on_tag_id ON public.featured_tags USING btree (tag_id);


--
-- Name: index_follow_requests_on_account_id_and_target_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_follow_requests_on_account_id_and_target_account_id ON public.follow_requests USING btree (account_id, target_account_id);


--
-- Name: index_follows_on_account_id_and_target_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_follows_on_account_id_and_target_account_id ON public.follows USING btree (account_id, target_account_id);


--
-- Name: index_follows_on_target_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_follows_on_target_account_id ON public.follows USING btree (target_account_id);


--
-- Name: index_group_accounts_on_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_group_accounts_on_account_id ON public.group_accounts USING btree (account_id);


--
-- Name: index_group_accounts_on_account_id_and_group_id; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_group_accounts_on_account_id_and_group_id ON public.group_accounts USING btree (account_id, group_id);


--
-- Name: index_group_accounts_on_group_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_group_accounts_on_group_id ON public.group_accounts USING btree (group_id);


--
-- Name: index_group_accounts_on_group_id_and_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_group_accounts_on_group_id_and_account_id ON public.group_accounts USING btree (group_id, account_id);


--
-- Name: index_group_removed_accounts_on_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_group_removed_accounts_on_account_id ON public.group_removed_accounts USING btree (account_id);


--
-- Name: index_group_removed_accounts_on_account_id_and_group_id; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_group_removed_accounts_on_account_id_and_group_id ON public.group_removed_accounts USING btree (account_id, group_id);


--
-- Name: index_group_removed_accounts_on_group_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_group_removed_accounts_on_group_id ON public.group_removed_accounts USING btree (group_id);


--
-- Name: index_group_removed_accounts_on_group_id_and_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_group_removed_accounts_on_group_id_and_account_id ON public.group_removed_accounts USING btree (group_id, account_id);


--
-- Name: index_groups_on_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_groups_on_account_id ON public.groups USING btree (account_id);


--
-- Name: index_identities_on_user_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_identities_on_user_id ON public.identities USING btree (user_id);


--
-- Name: index_invites_on_code; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_invites_on_code ON public.invites USING btree (code);


--
-- Name: index_invites_on_user_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_invites_on_user_id ON public.invites USING btree (user_id);


--
-- Name: index_list_accounts_on_account_id_and_list_id; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_list_accounts_on_account_id_and_list_id ON public.list_accounts USING btree (account_id, list_id);


--
-- Name: index_list_accounts_on_follow_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_list_accounts_on_follow_id ON public.list_accounts USING btree (follow_id);


--
-- Name: index_list_accounts_on_list_id_and_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_list_accounts_on_list_id_and_account_id ON public.list_accounts USING btree (list_id, account_id);


--
-- Name: index_lists_on_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_lists_on_account_id ON public.lists USING btree (account_id);


--
-- Name: index_media_attachments_on_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_media_attachments_on_account_id ON public.media_attachments USING btree (account_id);


--
-- Name: index_media_attachments_on_scheduled_status_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_media_attachments_on_scheduled_status_id ON public.media_attachments USING btree (scheduled_status_id);


--
-- Name: index_media_attachments_on_shortcode; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_media_attachments_on_shortcode ON public.media_attachments USING btree (shortcode);


--
-- Name: index_media_attachments_on_status_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_media_attachments_on_status_id ON public.media_attachments USING btree (status_id);


--
-- Name: index_mentions_on_account_id_and_status_id; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_mentions_on_account_id_and_status_id ON public.mentions USING btree (account_id, status_id);


--
-- Name: index_mentions_on_status_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_mentions_on_status_id ON public.mentions USING btree (status_id);


--
-- Name: index_mutes_on_account_id_and_target_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_mutes_on_account_id_and_target_account_id ON public.mutes USING btree (account_id, target_account_id);


--
-- Name: index_mutes_on_target_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_mutes_on_target_account_id ON public.mutes USING btree (target_account_id);


--
-- Name: index_notifications_on_account_id_and_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_notifications_on_account_id_and_id ON public.notifications USING btree (account_id, id DESC);


--
-- Name: index_notifications_on_activity_id_and_activity_type; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_notifications_on_activity_id_and_activity_type ON public.notifications USING btree (activity_id, activity_type);


--
-- Name: index_notifications_on_from_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_notifications_on_from_account_id ON public.notifications USING btree (from_account_id);


--
-- Name: index_oauth_access_grants_on_resource_owner_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_oauth_access_grants_on_resource_owner_id ON public.oauth_access_grants USING btree (resource_owner_id);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON public.oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON public.oauth_access_tokens USING btree (refresh_token);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON public.oauth_access_tokens USING btree (resource_owner_id);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON public.oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_owner_id_and_owner_type; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_oauth_applications_on_owner_id_and_owner_type ON public.oauth_applications USING btree (owner_id, owner_type);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON public.oauth_applications USING btree (uid);


--
-- Name: index_pghero_space_stats_on_database_and_captured_at; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_pghero_space_stats_on_database_and_captured_at ON public.pghero_space_stats USING btree (database, captured_at);


--
-- Name: index_poll_votes_on_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_poll_votes_on_account_id ON public.poll_votes USING btree (account_id);


--
-- Name: index_poll_votes_on_poll_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_poll_votes_on_poll_id ON public.poll_votes USING btree (poll_id);


--
-- Name: index_polls_on_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_polls_on_account_id ON public.polls USING btree (account_id);


--
-- Name: index_polls_on_status_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_polls_on_status_id ON public.polls USING btree (status_id);


--
-- Name: index_preview_cards_on_url; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_preview_cards_on_url ON public.preview_cards USING btree (url);


--
-- Name: index_preview_cards_statuses_on_status_id_and_preview_card_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_preview_cards_statuses_on_status_id_and_preview_card_id ON public.preview_cards_statuses USING btree (status_id, preview_card_id);


--
-- Name: index_report_notes_on_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_report_notes_on_account_id ON public.report_notes USING btree (account_id);


--
-- Name: index_report_notes_on_report_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_report_notes_on_report_id ON public.report_notes USING btree (report_id);


--
-- Name: index_reports_on_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_reports_on_account_id ON public.reports USING btree (account_id);


--
-- Name: index_reports_on_target_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_reports_on_target_account_id ON public.reports USING btree (target_account_id);


--
-- Name: index_scheduled_statuses_on_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_scheduled_statuses_on_account_id ON public.scheduled_statuses USING btree (account_id);


--
-- Name: index_scheduled_statuses_on_scheduled_at; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_scheduled_statuses_on_scheduled_at ON public.scheduled_statuses USING btree (scheduled_at);


--
-- Name: index_session_activations_on_access_token_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_session_activations_on_access_token_id ON public.session_activations USING btree (access_token_id);


--
-- Name: index_session_activations_on_session_id; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_session_activations_on_session_id ON public.session_activations USING btree (session_id);


--
-- Name: index_session_activations_on_user_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_session_activations_on_user_id ON public.session_activations USING btree (user_id);


--
-- Name: index_settings_on_thing_type_and_thing_id_and_var; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_settings_on_thing_type_and_thing_id_and_var ON public.settings USING btree (thing_type, thing_id, var);


--
-- Name: index_site_uploads_on_var; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_site_uploads_on_var ON public.site_uploads USING btree (var);


--
-- Name: index_status_pins_on_account_id_and_status_id; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_status_pins_on_account_id_and_status_id ON public.status_pins USING btree (account_id, status_id);


--
-- Name: index_status_stats_on_status_id; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_status_stats_on_status_id ON public.status_stats USING btree (status_id);


--
-- Name: index_statuses_20180106; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_statuses_20180106 ON public.statuses USING btree (account_id, id DESC, visibility, updated_at);


--
-- Name: index_statuses_on_group_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_statuses_on_group_id ON public.statuses USING btree (group_id);


--
-- Name: index_statuses_on_in_reply_to_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_statuses_on_in_reply_to_account_id ON public.statuses USING btree (in_reply_to_account_id);


--
-- Name: index_statuses_on_in_reply_to_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_statuses_on_in_reply_to_id ON public.statuses USING btree (in_reply_to_id);


--
-- Name: index_statuses_on_quote_of_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_statuses_on_quote_of_id ON public.statuses USING btree (quote_of_id);


--
-- Name: index_statuses_on_reblog_of_id_and_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_statuses_on_reblog_of_id_and_account_id ON public.statuses USING btree (reblog_of_id, account_id);


--
-- Name: index_statuses_on_uri; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_statuses_on_uri ON public.statuses USING btree (uri);


--
-- Name: index_statuses_tags_on_status_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_statuses_tags_on_status_id ON public.statuses_tags USING btree (status_id);


--
-- Name: index_statuses_tags_on_tag_id_and_status_id; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_statuses_tags_on_tag_id_and_status_id ON public.statuses_tags USING btree (tag_id, status_id);


--
-- Name: index_stream_entries_on_account_id_and_activity_type_and_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_stream_entries_on_account_id_and_activity_type_and_id ON public.stream_entries USING btree (account_id, activity_type, id);


--
-- Name: index_stream_entries_on_activity_id_and_activity_type; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_stream_entries_on_activity_id_and_activity_type ON public.stream_entries USING btree (activity_id, activity_type);


--
-- Name: index_subscriptions_on_account_id_and_callback_url; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_subscriptions_on_account_id_and_callback_url ON public.subscriptions USING btree (account_id, callback_url);


--
-- Name: index_tags_on_name; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_tags_on_name ON public.tags USING btree (name);


--
-- Name: index_tombstones_on_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_tombstones_on_account_id ON public.tombstones USING btree (account_id);


--
-- Name: index_tombstones_on_uri; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_tombstones_on_uri ON public.tombstones USING btree (uri);


--
-- Name: index_unique_conversations; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_unique_conversations ON public.account_conversations USING btree (account_id, conversation_id, participant_account_ids);


--
-- Name: index_user_invite_requests_on_user_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_user_invite_requests_on_user_id ON public.user_invite_requests USING btree (user_id);


--
-- Name: index_users_on_account_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_users_on_account_id ON public.users USING btree (account_id);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: index_users_on_created_by_application_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_users_on_created_by_application_id ON public.users USING btree (created_by_application_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_web_push_subscriptions_on_access_token_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_web_push_subscriptions_on_access_token_id ON public.web_push_subscriptions USING btree (access_token_id);


--
-- Name: index_web_push_subscriptions_on_user_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_web_push_subscriptions_on_user_id ON public.web_push_subscriptions USING btree (user_id);


--
-- Name: index_web_settings_on_user_id; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_web_settings_on_user_id ON public.web_settings USING btree (user_id);


--
-- Name: search_index; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX search_index ON public.accounts USING gin ((((setweight(to_tsvector('simple'::regconfig, (display_name)::text), 'A'::"char") || setweight(to_tsvector('simple'::regconfig, (username)::text), 'B'::"char")) || setweight(to_tsvector('simple'::regconfig, (COALESCE(domain, ''::character varying))::text), 'C'::"char"))));


--
-- Name: web_settings fk_11910667b2; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.web_settings
    ADD CONSTRAINT fk_11910667b2 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: account_domain_blocks fk_206c6029bd; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_domain_blocks
    ADD CONSTRAINT fk_206c6029bd FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: conversation_mutes fk_225b4212bb; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.conversation_mutes
    ADD CONSTRAINT fk_225b4212bb FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: statuses_tags fk_3081861e21; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.statuses_tags
    ADD CONSTRAINT fk_3081861e21 FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE;


--
-- Name: follows fk_32ed1b5560; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.follows
    ADD CONSTRAINT fk_32ed1b5560 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: oauth_access_grants fk_34d54b0a33; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT fk_34d54b0a33 FOREIGN KEY (application_id) REFERENCES public.oauth_applications(id) ON DELETE CASCADE;


--
-- Name: blocks fk_4269e03e65; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT fk_4269e03e65 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: reports fk_4b81f7522c; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT fk_4b81f7522c FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: users fk_50500f500d; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_50500f500d FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: stream_entries fk_5659b17554; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.stream_entries
    ADD CONSTRAINT fk_5659b17554 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: favourites fk_5eb6c2b873; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.favourites
    ADD CONSTRAINT fk_5eb6c2b873 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: oauth_access_grants fk_63b044929b; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT fk_63b044929b FOREIGN KEY (resource_owner_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: imports fk_6db1b6e408; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.imports
    ADD CONSTRAINT fk_6db1b6e408 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: follows fk_745ca29eac; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.follows
    ADD CONSTRAINT fk_745ca29eac FOREIGN KEY (target_account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: follow_requests fk_76d644b0e7; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.follow_requests
    ADD CONSTRAINT fk_76d644b0e7 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: follow_requests fk_9291ec025d; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.follow_requests
    ADD CONSTRAINT fk_9291ec025d FOREIGN KEY (target_account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: blocks fk_9571bfabc1; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT fk_9571bfabc1 FOREIGN KEY (target_account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: session_activations fk_957e5bda89; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.session_activations
    ADD CONSTRAINT fk_957e5bda89 FOREIGN KEY (access_token_id) REFERENCES public.oauth_access_tokens(id) ON DELETE CASCADE;


--
-- Name: media_attachments fk_96dd81e81b; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.media_attachments
    ADD CONSTRAINT fk_96dd81e81b FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE SET NULL;


--
-- Name: mentions fk_970d43f9d1; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.mentions
    ADD CONSTRAINT fk_970d43f9d1 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: subscriptions fk_9847d1cbb5; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT fk_9847d1cbb5 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: statuses fk_9bda1543f7; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.statuses
    ADD CONSTRAINT fk_9bda1543f7 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: oauth_applications fk_b0988c7c0a; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.oauth_applications
    ADD CONSTRAINT fk_b0988c7c0a FOREIGN KEY (owner_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: favourites fk_b0e856845e; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.favourites
    ADD CONSTRAINT fk_b0e856845e FOREIGN KEY (status_id) REFERENCES public.statuses(id) ON DELETE CASCADE;


--
-- Name: mutes fk_b8d8daf315; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.mutes
    ADD CONSTRAINT fk_b8d8daf315 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: reports fk_bca45b75fd; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT fk_bca45b75fd FOREIGN KEY (action_taken_by_account_id) REFERENCES public.accounts(id) ON DELETE SET NULL;


--
-- Name: identities fk_bea040f377; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.identities
    ADD CONSTRAINT fk_bea040f377 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: notifications fk_c141c8ee55; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT fk_c141c8ee55 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: statuses fk_c7fa917661; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.statuses
    ADD CONSTRAINT fk_c7fa917661 FOREIGN KEY (in_reply_to_account_id) REFERENCES public.accounts(id) ON DELETE SET NULL;


--
-- Name: status_pins fk_d4cb435b62; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.status_pins
    ADD CONSTRAINT fk_d4cb435b62 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: session_activations fk_e5fda67334; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.session_activations
    ADD CONSTRAINT fk_e5fda67334 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: oauth_access_tokens fk_e84df68546; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT fk_e84df68546 FOREIGN KEY (resource_owner_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: reports fk_eb37af34f0; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT fk_eb37af34f0 FOREIGN KEY (target_account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: mutes fk_eecff219ea; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.mutes
    ADD CONSTRAINT fk_eecff219ea FOREIGN KEY (target_account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: oauth_access_tokens fk_f5fc4c1ee3; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT fk_f5fc4c1ee3 FOREIGN KEY (application_id) REFERENCES public.oauth_applications(id) ON DELETE CASCADE;


--
-- Name: notifications fk_fbd6b0bf9e; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT fk_fbd6b0bf9e FOREIGN KEY (from_account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: group_accounts fk_rails_074961f348; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.group_accounts
    ADD CONSTRAINT fk_rails_074961f348 FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: backups fk_rails_096669d221; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.backups
    ADD CONSTRAINT fk_rails_096669d221 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: account_conversations fk_rails_1491654f9f; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_conversations
    ADD CONSTRAINT fk_rails_1491654f9f FOREIGN KEY (conversation_id) REFERENCES public.conversations(id) ON DELETE CASCADE;


--
-- Name: featured_tags fk_rails_174efcf15f; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.featured_tags
    ADD CONSTRAINT fk_rails_174efcf15f FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: account_tag_stats fk_rails_1fa34bab2d; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_tag_stats
    ADD CONSTRAINT fk_rails_1fa34bab2d FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE;


--
-- Name: account_stats fk_rails_215bb31ff1; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_stats
    ADD CONSTRAINT fk_rails_215bb31ff1 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: accounts fk_rails_2320833084; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT fk_rails_2320833084 FOREIGN KEY (moved_to_account_id) REFERENCES public.accounts(id) ON DELETE SET NULL;


--
-- Name: featured_tags fk_rails_23a9055c7c; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.featured_tags
    ADD CONSTRAINT fk_rails_23a9055c7c FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE;


--
-- Name: scheduled_statuses fk_rails_23bd9018f9; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.scheduled_statuses
    ADD CONSTRAINT fk_rails_23bd9018f9 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: statuses fk_rails_256483a9ab; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.statuses
    ADD CONSTRAINT fk_rails_256483a9ab FOREIGN KEY (reblog_of_id) REFERENCES public.statuses(id) ON DELETE CASCADE;


--
-- Name: statuses fk_rails_30016aba2f; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.statuses
    ADD CONSTRAINT fk_rails_30016aba2f FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE SET NULL;


--
-- Name: media_attachments fk_rails_31fc5aeef1; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.media_attachments
    ADD CONSTRAINT fk_rails_31fc5aeef1 FOREIGN KEY (scheduled_status_id) REFERENCES public.scheduled_statuses(id) ON DELETE SET NULL;


--
-- Name: user_invite_requests fk_rails_3773f15361; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.user_invite_requests
    ADD CONSTRAINT fk_rails_3773f15361 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: lists fk_rails_3853b78dac; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.lists
    ADD CONSTRAINT fk_rails_3853b78dac FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: polls fk_rails_3e0d9f1115; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.polls
    ADD CONSTRAINT fk_rails_3e0d9f1115 FOREIGN KEY (status_id) REFERENCES public.statuses(id) ON DELETE CASCADE;


--
-- Name: media_attachments fk_rails_3ec0cfdd70; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.media_attachments
    ADD CONSTRAINT fk_rails_3ec0cfdd70 FOREIGN KEY (status_id) REFERENCES public.statuses(id) ON DELETE SET NULL;


--
-- Name: account_moderation_notes fk_rails_3f8b75089b; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_moderation_notes
    ADD CONSTRAINT fk_rails_3f8b75089b FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: list_accounts fk_rails_40f9cc29f1; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.list_accounts
    ADD CONSTRAINT fk_rails_40f9cc29f1 FOREIGN KEY (follow_id) REFERENCES public.follows(id) ON DELETE CASCADE;


--
-- Name: status_stats fk_rails_4a247aac42; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.status_stats
    ADD CONSTRAINT fk_rails_4a247aac42 FOREIGN KEY (status_id) REFERENCES public.statuses(id) ON DELETE CASCADE;


--
-- Name: reports fk_rails_4e7a498fb4; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT fk_rails_4e7a498fb4 FOREIGN KEY (assigned_account_id) REFERENCES public.accounts(id) ON DELETE SET NULL;


--
-- Name: mentions fk_rails_59edbe2887; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.mentions
    ADD CONSTRAINT fk_rails_59edbe2887 FOREIGN KEY (status_id) REFERENCES public.statuses(id) ON DELETE CASCADE;


--
-- Name: conversation_mutes fk_rails_5ab139311f; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.conversation_mutes
    ADD CONSTRAINT fk_rails_5ab139311f FOREIGN KEY (conversation_id) REFERENCES public.conversations(id) ON DELETE CASCADE;


--
-- Name: polls fk_rails_5b19a0c011; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.polls
    ADD CONSTRAINT fk_rails_5b19a0c011 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: group_accounts fk_rails_6339461ba9; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.group_accounts
    ADD CONSTRAINT fk_rails_6339461ba9 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: status_pins fk_rails_65c05552f1; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.status_pins
    ADD CONSTRAINT fk_rails_65c05552f1 FOREIGN KEY (status_id) REFERENCES public.statuses(id) ON DELETE CASCADE;


--
-- Name: account_identity_proofs fk_rails_6a219ca385; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_identity_proofs
    ADD CONSTRAINT fk_rails_6a219ca385 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: account_conversations fk_rails_6f5278b6e9; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_conversations
    ADD CONSTRAINT fk_rails_6f5278b6e9 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: group_removed_accounts fk_rails_734302b7f7; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.group_removed_accounts
    ADD CONSTRAINT fk_rails_734302b7f7 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: web_push_subscriptions fk_rails_751a9f390b; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.web_push_subscriptions
    ADD CONSTRAINT fk_rails_751a9f390b FOREIGN KEY (access_token_id) REFERENCES public.oauth_access_tokens(id) ON DELETE CASCADE;


--
-- Name: report_notes fk_rails_7fa83a61eb; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.report_notes
    ADD CONSTRAINT fk_rails_7fa83a61eb FOREIGN KEY (report_id) REFERENCES public.reports(id) ON DELETE CASCADE;


--
-- Name: list_accounts fk_rails_85fee9d6ab; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.list_accounts
    ADD CONSTRAINT fk_rails_85fee9d6ab FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: group_removed_accounts fk_rails_87c1da72a2; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.group_removed_accounts
    ADD CONSTRAINT fk_rails_87c1da72a2 FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: custom_filters fk_rails_8b8d786993; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.custom_filters
    ADD CONSTRAINT fk_rails_8b8d786993 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: users fk_rails_8fb2a43e88; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_8fb2a43e88 FOREIGN KEY (invite_id) REFERENCES public.invites(id) ON DELETE SET NULL;


--
-- Name: statuses fk_rails_94a6f70399; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.statuses
    ADD CONSTRAINT fk_rails_94a6f70399 FOREIGN KEY (in_reply_to_id) REFERENCES public.statuses(id) ON DELETE SET NULL;


--
-- Name: account_pins fk_rails_a176e26c37; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_pins
    ADD CONSTRAINT fk_rails_a176e26c37 FOREIGN KEY (target_account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: account_warnings fk_rails_a65a1bf71b; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_warnings
    ADD CONSTRAINT fk_rails_a65a1bf71b FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE SET NULL;


--
-- Name: poll_votes fk_rails_a6e6974b7e; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.poll_votes
    ADD CONSTRAINT fk_rails_a6e6974b7e FOREIGN KEY (poll_id) REFERENCES public.polls(id) ON DELETE CASCADE;


--
-- Name: admin_action_logs fk_rails_a7667297fa; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.admin_action_logs
    ADD CONSTRAINT fk_rails_a7667297fa FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: account_warnings fk_rails_a7ebbb1e37; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_warnings
    ADD CONSTRAINT fk_rails_a7ebbb1e37 FOREIGN KEY (target_account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: web_push_subscriptions fk_rails_b006f28dac; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.web_push_subscriptions
    ADD CONSTRAINT fk_rails_b006f28dac FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: poll_votes fk_rails_b6c18cf44a; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.poll_votes
    ADD CONSTRAINT fk_rails_b6c18cf44a FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: statuses fk_rails_c239e54616; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.statuses
    ADD CONSTRAINT fk_rails_c239e54616 FOREIGN KEY (quote_of_id) REFERENCES public.statuses(id) ON DELETE SET NULL;


--
-- Name: report_notes fk_rails_cae66353f3; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.report_notes
    ADD CONSTRAINT fk_rails_cae66353f3 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: account_pins fk_rails_d44979e5dd; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_pins
    ADD CONSTRAINT fk_rails_d44979e5dd FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: account_moderation_notes fk_rails_dd62ed5ac3; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.account_moderation_notes
    ADD CONSTRAINT fk_rails_dd62ed5ac3 FOREIGN KEY (target_account_id) REFERENCES public.accounts(id);


--
-- Name: statuses_tags fk_rails_df0fe11427; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.statuses_tags
    ADD CONSTRAINT fk_rails_df0fe11427 FOREIGN KEY (status_id) REFERENCES public.statuses(id) ON DELETE CASCADE;


--
-- Name: deprecated_preview_cards fk_rails_e0cd3ac7fe; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.deprecated_preview_cards
    ADD CONSTRAINT fk_rails_e0cd3ac7fe FOREIGN KEY (status_id) REFERENCES public.statuses(id) ON DELETE CASCADE;


--
-- Name: list_accounts fk_rails_e54e356c88; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.list_accounts
    ADD CONSTRAINT fk_rails_e54e356c88 FOREIGN KEY (list_id) REFERENCES public.lists(id) ON DELETE CASCADE;


--
-- Name: users fk_rails_ecc9536e7c; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_ecc9536e7c FOREIGN KEY (created_by_application_id) REFERENCES public.oauth_applications(id) ON DELETE SET NULL;


--
-- Name: tombstones fk_rails_f95b861449; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.tombstones
    ADD CONSTRAINT fk_rails_f95b861449 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: invites fk_rails_ff69dbb2ac; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.invites
    ADD CONSTRAINT fk_rails_ff69dbb2ac FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

