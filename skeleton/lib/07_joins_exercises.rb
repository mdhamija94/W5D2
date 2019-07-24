# == Schema Information
#
# Table name: actors
#
#  id          :integer      not null, primary key
#  name        :string
#
# Table name: movies
#
#  id          :integer      not null, primary key
#  title       :string
#  yr          :integer
#  score       :float
#  votes       :integer
#  director_id :integer
#
# Table name: castings
#
#  movie_id    :integer      not null, primary key
#  actor_id    :integer      not null, primary key
#  ord         :integer

require_relative './sqlzoo.rb'

def example_join
  execute(<<-SQL)
    SELECT
      *
    FROM
      movies
    JOIN
      castings ON movies.id = castings.movie_id
    JOIN
      actors ON castings.actor_id = actors.id
    WHERE
      actors.name = 'Sean Connery'
  SQL
end

def ford_films
  # List the films in which 'Harrison Ford' has appeared.
  execute(<<-SQL)
    SELECT title
    FROM movies
    JOIN castings ON movies.id = castings.movie_id
    JOIN actors ON castings.actor_id = actors.id
    WHERE actors.name = 'Harrison Ford' 
  SQL
end

def ford_supporting_films
  # List the films where 'Harrison Ford' has appeared - but not in the star
  # role. [Note: the ord field of casting gives the position of the actor. If
  # ord=1 then this actor is in the starring role]
  execute(<<-SQL)
    SELECT title
    FROM movies
    JOIN castings ON movies.id = castings.movie_id
    JOIN actors ON castings.actor_id = actors.id
    WHERE actors.name = 'Harrison Ford'
    AND castings.ord <> 1
  SQL
end

def films_and_stars_from_sixty_two
  # List the title and leading star of every 1962 film.
  execute(<<-SQL)
    SELECT movies.title AS sixtytwo_movies, actors.name AS leading_star
    FROM movies
    JOIN castings ON castings.movie_id = movies.id
    JOIN actors ON castings.actor_id = actors.id
    WHERE movies.yr = 1962
    AND castings.ord = 1
  SQL
end

def travoltas_busiest_years
  # Which were the busiest years for 'John Travolta'? Show the year and the
  # number of movies he made for any year in which he made at least 2 movies.
  execute(<<-SQL)
    SELECT movies.yr, COUNT(movies.id) AS num_movies
    FROM movies
    JOIN castings ON movies.id = castings.movie_id
    JOIN actors ON castings.actor_id = actors.id
    WHERE actors.name = 'John Travolta'
    GROUP BY movies.yr
    HAVING COUNT(movies.id) >= 2
  SQL
end

def andrews_films_and_leads
  # List the film title and the leading actor for all of the films 'Julie
  # Andrews' played in.
  execute(<<-SQL)
    SELECT julie_andrews_movies.title, actors.name
    FROM (
      SELECT movies.id, movies.title
      FROM movies
      JOIN castings ON movies.id = castings.movie_id
      JOIN actors ON castings.actor_id = actors.id
      WHERE actors.name = 'Julie Andrews'
      ) AS julie_andrews_movies
    JOIN castings ON julie_andrews_movies.id = castings.movie_id
    JOIN actors ON castings.actor_id = actors.id
    WHERE castings.ord = 1
  SQL
end

def prolific_actors
  # Obtain a list in alphabetical order of actors who've had at least 15
  # starring roles.
  execute(<<-SQL)
    SELECT actors.name
    FROM (
      SELECT actor_id, count(actor_id) as num_lead_roles
      FROM castings
      WHERE ord = 1
      GROUP BY actor_id
    ) AS leading_role_count
    JOIN actors ON leading_role_count.actor_id = actors.id
    WHERE num_lead_roles >= 15
    ORDER BY actors.name
  SQL
end

def films_by_cast_size
  # List the films released in the year 1978 ordered by the number of actors
  # in the cast (descending), then by title (ascending).
  execute(<<-SQL)
    SELECT movies.title, num_actors
    FROM (
      SELECT movie_id, COUNT(actor_id) as num_actors
      FROM castings
      GROUP BY movie_id
    ) AS actor_count
    JOIN movies ON actor_count.movie_id = movies.id
    WHERE yr = 1978
    ORDER BY num_actors DESC, movies.title ASC
  SQL
end

def colleagues_of_garfunkel
  # List all the people who have played alongside 'Art Garfunkel'.
  execute(<<-SQL)
    SELECT actors.name
    FROM (
      SELECT movies.id, movies.title
      FROM movies
      JOIN castings ON movies.id = castings.movie_id
      JOIN actors ON castings.actor_id = actors.id
      WHERE actors.name = 'Art Garfunkel'
      ) AS art_garfunkel_movies
    JOIN castings ON art_garfunkel_movies.id = castings.movie_id
    JOIN actors ON castings.actor_id = actors.id
    WHERE actors.name <> 'Art Garfunkel'
  SQL
end
