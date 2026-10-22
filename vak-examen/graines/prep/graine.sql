-- Graine « prep » (créateur de quiz). Usage : psql -v a=<uuid de A> -v b=<uuid de B> -f graine.sql
-- A : 6 quizzes (tous publiés, avec code), 4 notes (quiz_ratings) données sur ses propres quiz publics. B : 5 quizzes en brouillon
-- (non lisibles par A sous la RLS de l'app, qui ne montre que les quiz publiés ou les siens), chaque texte libre porte un marqueur.
\set ON_ERROR_STOP on
begin;

insert into public.quizzes (title, description, created_by, category, difficulty, visibility, status, code, time_limit, created_at) values
  ('World Capitals Challenge', 'Test your knowledge of national capitals.', :'a'::uuid, 'Geography', 'Beginner', 'public', 'published', 'WCAP01', 20, '2026-05-10'),
  ('Intro to Photosynthesis', 'Plants, light and energy.', :'a'::uuid, 'Science', 'Intermediate', 'public', 'published', 'PHOT02', 15, '2026-05-11'),
  ('French Revolution Basics', 'Key dates and figures from 1789.', :'a'::uuid, 'History', 'Intermediate', 'private', 'published', 'FREV03', null, '2026-05-12'),
  ('Algebra Warm-up', 'Quick equations to start the day.', :'a'::uuid, 'Mathematics', 'Beginner', 'public', 'published', 'ALGB04', 10, '2026-05-13'),
  ('Web Technologies 101', 'HTML, CSS and HTTP fundamentals.', :'a'::uuid, 'Technology', 'Beginner', 'public', 'published', 'WEBT05', null, '2026-05-14'),
  ('Modern Art Movements', 'From Impressionism to Pop Art.', :'a'::uuid, 'Arts & Culture', 'Advanced', 'private', 'published', 'MART06', 30, '2026-05-15'),
  ('Quiz MARQUEUR-B-78E75094', 'Description MARQUEUR-B-D7250571', :'b'::uuid, 'Science', 'Beginner', 'public', 'draft', null, null, '2026-06-10'),
  ('Quiz MARQUEUR-B-ADF284B6', 'Description MARQUEUR-B-543F356D', :'b'::uuid, 'History', 'Beginner', 'private', 'draft', null, null, '2026-06-11'),
  ('Quiz MARQUEUR-B-2BB92BCF', 'Description MARQUEUR-B-F8E9D9B3', :'b'::uuid, 'Technology', 'Beginner', 'public', 'draft', null, null, '2026-06-12'),
  ('Quiz MARQUEUR-B-17020F49', 'Description MARQUEUR-B-098EE0CE', :'b'::uuid, 'Geography', 'Beginner', 'private', 'draft', null, null, '2026-06-13'),
  ('Quiz MARQUEUR-B-64512A23', 'Description MARQUEUR-B-3722DCD5', :'b'::uuid, 'Mathematics', 'Beginner', 'public', 'draft', null, null, '2026-06-14');

insert into public.questions (quiz_id, "Question", "Option_A", "Option_B", "Option_C", "Option_D", "Correct_Answer", "Points")
select q.id, v.qu, v.a, v.b, v.c, v.d, v.ok, 1
from (values
  ('World Capitals Challenge', 'What is the capital of Australia?', 'Sydney', 'Canberra', 'Melbourne', 'Perth', 'B'),
  ('World Capitals Challenge', 'What is the capital of Canada?', 'Toronto', 'Vancouver', 'Ottawa', 'Montreal', 'C'),
  ('Algebra Warm-up', 'Solve: 2x + 4 = 10', 'x = 2', 'x = 3', 'x = 4', 'x = 5', 'B'),
  ('Quiz MARQUEUR-B-78E75094', 'Question MARQUEUR-B-73BC04C3', 'Option MARQUEUR-B-D4E335DE', 'Option MARQUEUR-B-9AF06AC4', 'Option MARQUEUR-B-F0FEE9E1', 'Option MARQUEUR-B-94B19100', 'A'),
  ('Quiz MARQUEUR-B-ADF284B6', 'Question MARQUEUR-B-AB5DEC0C', 'Option MARQUEUR-B-4C3763C8', 'Option MARQUEUR-B-DBFAB144', 'Option MARQUEUR-B-588C65C2', 'Option MARQUEUR-B-8A76E8CA', 'A'),
  ('Quiz MARQUEUR-B-2BB92BCF', 'Question MARQUEUR-B-D7551AEF', 'Option MARQUEUR-B-CB7E979B', 'Option MARQUEUR-B-35903044', 'Option MARQUEUR-B-3192A2D4', 'Option MARQUEUR-B-9DC46605', 'A'),
  ('Quiz MARQUEUR-B-17020F49', 'Question MARQUEUR-B-4370E5A6', 'Option MARQUEUR-B-F2C9F84D', 'Option MARQUEUR-B-7A004E02', 'Option MARQUEUR-B-141FB441', 'Option MARQUEUR-B-A7B739E6', 'A'),
  ('Quiz MARQUEUR-B-64512A23', 'Question MARQUEUR-B-110E81CE', 'Option MARQUEUR-B-416F272C', 'Option MARQUEUR-B-58D82DD4', 'Option MARQUEUR-B-78238B98', 'Option MARQUEUR-B-44C69666', 'A')
) as v(title, qu, a, b, c, d, ok)
join public.quizzes q on q.title = v.title;

insert into public.quiz_ratings (quiz_id, user_id, rating)
select q.id, :'a'::uuid, v.rating
from (values
  ('World Capitals Challenge', 5),
  ('Intro to Photosynthesis', 4),
  ('Algebra Warm-up', 3),
  ('Web Technologies 101', 4)
) as v(title, rating)
join public.quizzes q on q.title = v.title and q.created_by = :'a'::uuid;

-- B note ses propres quiz (publics) : les notes de B ne portent pas de texte libre.
insert into public.quiz_ratings (quiz_id, user_id, rating)
select id, :'b'::uuid, 4 from public.quizzes where created_by = :'b'::uuid and visibility = 'public';

commit;
