-- Graine « cuisine » (carnet de cuisine). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A : 7 recettes, 12 cuissons. B : 4 recettes, 6 cuissons, chaque texte libre porte un marqueur unique.
\set ON_ERROR_STOP on
begin;

insert into public.recipes (title, category, prep_minutes, servings, is_favorite, keywords, user_id) values
  ('Soupe à l''oignon', 'entree', 45, 4, true, '{soupe,hiver}', :'a'::uuid),
  ('Salade de chèvre chaud', 'entree', 20, 2, false, '{salade,fromage}', :'a'::uuid),
  ('Boeuf bourguignon', 'plat', 180, 6, true, '{mijoté,viande}', :'a'::uuid),
  ('Ratatouille', 'plat', 60, 4, false, '{légumes,été}', :'a'::uuid),
  ('Tarte tatin', 'dessert', 75, 8, true, '{pommes,caramel}', :'a'::uuid),
  ('Mousse au chocolat', 'dessert', 30, 6, false, '{chocolat}', :'a'::uuid),
  ('Citronnade maison', 'boisson', 10, 4, false, '{citron,été}', :'a'::uuid),
  ('Recette MARQUEUR-B-4F1A9C20', 'plat', 50, 4, true, '{MARQUEUR-B-0B7D3E51}', :'b'::uuid),
  ('Recette MARQUEUR-B-C83E27D4', 'entree', 25, 2, false, '{MARQUEUR-B-92A6F1B8}', :'b'::uuid),
  ('Recette MARQUEUR-B-5D90B6AE', 'dessert', 40, 6, false, '{MARQUEUR-B-E1347C0F}', :'b'::uuid),
  ('Recette MARQUEUR-B-A2C45E19', 'boisson', 5, 1, true, '{MARQUEUR-B-7F08D5C3}', :'b'::uuid);

insert into public.cookings (recipe_id, cooked_on, rating, comment, user_id)
select r.id, v.cooked_on::date, v.rating, v.comment, r.user_id
from (values
  ('Soupe à l''oignon', '2026-01-10', 4, 'Un peu salée', :'a'::uuid),
  ('Soupe à l''oignon', '2026-02-14', 5, 'Parfaite', :'a'::uuid),
  ('Salade de chèvre chaud', '2026-03-03', 3, 'Trop de vinaigre', :'a'::uuid),
  ('Boeuf bourguignon', '2026-01-25', 5, 'Fondant', :'a'::uuid),
  ('Boeuf bourguignon', '2026-03-22', 4, 'Cuisson un peu courte', :'a'::uuid),
  ('Boeuf bourguignon', '2026-04-12', 5, 'Pour les invités', :'a'::uuid),
  ('Ratatouille', '2026-07-08', 4, 'Légumes du marché', :'a'::uuid),
  ('Ratatouille', '2026-08-02', 3, 'Trop d''huile', :'a'::uuid),
  ('Tarte tatin', '2026-10-01', 5, 'Caramel réussi', :'a'::uuid),
  ('Tarte tatin', '2026-10-05', 4, 'Pâte trop cuite', :'a'::uuid),
  ('Mousse au chocolat', '2026-05-09', 5, 'Très onctueuse', :'a'::uuid),
  ('Citronnade maison', '2026-07-20', 4, 'Rafraîchissante', :'a'::uuid),
  ('Recette MARQUEUR-B-4F1A9C20', '2026-01-11', 4, 'Avis MARQUEUR-B-18D2E6A7', :'b'::uuid),
  ('Recette MARQUEUR-B-4F1A9C20', '2026-02-12', 3, 'Avis MARQUEUR-B-B49053FC', :'b'::uuid),
  ('Recette MARQUEUR-B-C83E27D4', '2026-03-13', 5, 'Avis MARQUEUR-B-6C7A10E2', :'b'::uuid),
  ('Recette MARQUEUR-B-5D90B6AE', '2026-04-14', 2, 'Avis MARQUEUR-B-D5F38B94', :'b'::uuid),
  ('Recette MARQUEUR-B-5D90B6AE', '2026-05-15', 4, 'Avis MARQUEUR-B-3E81A7C6', :'b'::uuid),
  ('Recette MARQUEUR-B-A2C45E19', '2026-06-16', 5, 'Avis MARQUEUR-B-F0924D1B', :'b'::uuid)
) as v(title, cooked_on, rating, comment, owner)
join public.recipes r on r.title = v.title and r.user_id = v.owner;

commit;
