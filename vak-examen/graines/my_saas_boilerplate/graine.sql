-- Graine « my_saas_boilerplate » (ResizeSuite). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- public.users n'a pas de clé vers auth.users : son id EST l'id du compte (politiques : auth.uid() = id).
-- A : 1 profil, 6 journaux d'activité, 4 projets, 5 suivis d'usage, 3 paiements, 3 modèles de filigrane,
--     4 tickets, 2 clés d'API, 5 préréglages sociaux. B : des lignes différentes, chaque texte libre porte un marqueur.
-- Aucune ligne de A ni de B n'est publique (is_public = false) ; ni l'un ni l'autre n'est admin.
\set ON_ERROR_STOP on
begin;

insert into public.users (id, email, name, plan_name, subscription_status) values
  (:'a'::uuid, 'alice.martin@example.test', 'Alice Martin', 'pro', 'active'),
  (:'b'::uuid, 'marqueur-b-177bcad2@example.test', 'Nom MARQUEUR-B-2C39D910', 'free', null);

insert into public.activity_logs (user_id, action, ip_address) values
  (:'a'::uuid, 'Signed in', '192.0.2.10'),
  (:'a'::uuid, 'Resized 12 images', '192.0.2.11'),
  (:'a'::uuid, 'Downloaded ZIP archive', '192.0.2.12'),
  (:'a'::uuid, 'Created project', '192.0.2.13'),
  (:'a'::uuid, 'Updated profile', '192.0.2.14'),
  (:'a'::uuid, 'Signed out', '192.0.2.15'),
  (:'b'::uuid, 'Action MARQUEUR-B-4785D71D', '198.51.100.20'),
  (:'b'::uuid, 'Action MARQUEUR-B-E0E8E3F5', '198.51.100.21'),
  (:'b'::uuid, 'Action MARQUEUR-B-4F482E5A', '198.51.100.22'),
  (:'b'::uuid, 'Action MARQUEUR-B-7DE75AA4', '198.51.100.23');

insert into public.projects (user_id, name, description, tool_type) values
  (:'a'::uuid, 'Spring Campaign', 'Banner set for spring', 'resize'),
  (:'a'::uuid, 'Product Photos', 'Catalog thumbnails', 'compress'),
  (:'a'::uuid, 'Blog Headers', 'Header images for the blog', 'resize'),
  (:'a'::uuid, 'Team Portraits', 'Cropped team photos', 'crop'),
  (:'b'::uuid, 'Project MARQUEUR-B-74A7C8E5', 'Description MARQUEUR-B-8BB9C9E4', 'resize'),
  (:'b'::uuid, 'Project MARQUEUR-B-6E351E03', 'Description MARQUEUR-B-35EE496E', 'resize'),
  (:'b'::uuid, 'Project MARQUEUR-B-40242B33', 'Description MARQUEUR-B-6AED5927', 'resize');

insert into public.usage_tracking (user_id, feature_name, usage_count) values
  (:'a'::uuid, 'image_resize', 3),
  (:'a'::uuid, 'image_compress', 4),
  (:'a'::uuid, 'image_crop', 5),
  (:'a'::uuid, 'zip_download', 6),
  (:'a'::uuid, 'watermark_apply', 7),
  (:'b'::uuid, 'feature_MARQUEUR-B-A1DAD9CD', 1),
  (:'b'::uuid, 'feature_MARQUEUR-B-8FF91DA1', 2),
  (:'b'::uuid, 'feature_MARQUEUR-B-43A7D0FF', 3);

insert into public.payment_history (user_id, stripe_payment_intent_id, amount, currency, status, description) values
  (:'a'::uuid, 'pi_alice_0001', 999, 'usd', 'succeeded', 'Pro monthly plan - January'),
  (:'a'::uuid, 'pi_alice_0002', 999, 'usd', 'succeeded', 'Pro monthly plan - February'),
  (:'a'::uuid, 'pi_alice_0003', 999, 'usd', 'succeeded', 'Pro monthly plan - March'),
  (:'b'::uuid, 'pi_marqueur-b-f6017762', 1999, 'usd', 'succeeded', 'Payment MARQUEUR-B-F6017762'),
  (:'b'::uuid, 'pi_marqueur-b-8c24e688', 2000, 'usd', 'succeeded', 'Payment MARQUEUR-B-8C24E688');

insert into public.watermark_templates (user_id, name, description, template_data, is_public) values
  (:'a'::uuid, 'Studio Logo', 'My studio logo in the corner', '{"type":"image","position":"bottom-right"}', false),
  (:'a'::uuid, 'Draft Stamp', 'Diagonal draft stamp', '{"type":"text","text":"DRAFT"}', false),
  (:'a'::uuid, 'Client Preview', 'Light watermark for client previews', '{"type":"text","text":"PREVIEW"}', false),
  (:'b'::uuid, 'Template MARQUEUR-B-0E01E0D9', 'Description MARQUEUR-B-D8B3AC2A', '{"type":"text","text":"B"}', false),
  (:'b'::uuid, 'Template MARQUEUR-B-8D364194', 'Description MARQUEUR-B-7B5724F0', '{"type":"text","text":"B"}', false);

insert into public.support_tickets (user_id, subject, description, status, priority, resolution) values
  (:'a'::uuid, 'Cannot download ZIP', 'The ZIP download button does nothing', 'open', 'high', null),
  (:'a'::uuid, 'Invoice request', 'I need an invoice for March', 'resolved', 'low', 'Invoice sent by email'),
  (:'a'::uuid, 'Resize quality', 'Output looks blurry at 50 percent', 'in_progress', 'medium', null),
  (:'a'::uuid, 'Change of plan', 'How do I switch to yearly billing?', 'closed', 'low', 'Explained in the billing page'),
  (:'b'::uuid, 'Subject MARQUEUR-B-02A52608', 'Description MARQUEUR-B-AF9F09F7', 'open', 'medium', 'Resolution MARQUEUR-B-5287CDAE'),
  (:'b'::uuid, 'Subject MARQUEUR-B-D2FB5199', 'Description MARQUEUR-B-83FD26B9', 'resolved', 'medium', 'Resolution MARQUEUR-B-A5D3751D'),
  (:'b'::uuid, 'Subject MARQUEUR-B-0BF2B65E', 'Description MARQUEUR-B-BAA87EDC', 'resolved', 'medium', 'Resolution MARQUEUR-B-17E3E46A');

insert into public.api_keys (user_id, key_name, api_key) values
  (:'a'::uuid, 'Production key', 'rsk_alice_prod_0001'),
  (:'a'::uuid, 'Staging key', 'rsk_alice_stg_0002'),
  (:'b'::uuid, 'Key MARQUEUR-B-04D180D7', 'rsk_marqueur-b-1fbc91cf'),
  (:'b'::uuid, 'Key MARQUEUR-B-6C7D9A62', 'rsk_marqueur-b-f47eb57c'),
  (:'b'::uuid, 'Key MARQUEUR-B-01223DDE', 'rsk_marqueur-b-dd325208');

insert into public.social_presets (user_id, platform, preset_name, width, height, is_public) values
  (:'a'::uuid, 'instagram', 'Square Ad', 1080, 1080, false),
  (:'a'::uuid, 'facebook', 'Event Banner', 1200, 628, false),
  (:'a'::uuid, 'twitter', 'Launch Card', 1200, 675, false),
  (:'a'::uuid, 'linkedin', 'Job Post', 1200, 627, false),
  (:'a'::uuid, 'youtube', 'Channel Art', 2560, 1440, false),
  (:'b'::uuid, 'instagram', 'Preset MARQUEUR-B-6453BBF8', 1000, 1000, false),
  (:'b'::uuid, 'instagram', 'Preset MARQUEUR-B-C9972472', 1001, 1001, false),
  (:'b'::uuid, 'instagram', 'Preset MARQUEUR-B-4A3A294C', 1002, 1002, false);

commit;
