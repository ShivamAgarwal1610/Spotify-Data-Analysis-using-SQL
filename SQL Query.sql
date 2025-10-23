-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);


delete from spotify
where duration_min = 0


-- 1. Retrieve the names of all tracks that have more than 1 billion streams.

select * from spotify
where stream >= 1000000000

-- 2. List all albums along with their respective artists.

select distinct album , artist 
from spotify

-- 3. Get the total number of comments for tracks where licensed = TRUE.

select sum(comments) from spotify
where licensed = TRUE

-- 4. Find all tracks that belong to the album type single.

select track from spotify
where album_type =  'single'

-- 5.Count the total number of tracks by each artist.

select artist , count(*) as total_tracks 
from spotify
group by artist
order by total_tracks desc

-- 6. Calculate the average danceability of tracks in each album.

select album , avg(danceability) as average_danceability
from spotify
group by album
order by average_danceability desc

-- 7. Find the top 5 tracks with the highest energy values.

select track  from spotify
order by energy desc
limit 5

-- 8. List all tracks along with their views and likes where official_video = TRUE.

select track , sum(views) as total_views , sum(likes) total_likes
from spotify
where official_video = 'TRUE'
group by 1

-- 9. For each album, calculate the total views of all associated tracks.

select album ,track ,  sum(views) as total_view
from spotify
group by album , track
order by total_view desc

-- 10.Retrieve the track names that have been streamed on Spotify more than YouTube.

select * from 
(select track ,
coalesce(sum(case when most_played_on = 'youtube' then stream end ) , 0 ) as streamed_on_youtube ,
coalesce(sum(case when most_played_on = 'spotify' then stream end ),0) as streamed_on_spotify 
from spotify
group by 1
) as t1
where streamed_on_spotify > streamed_on_youtube
and streamed_on_youtube <> 0


-- 11. Find the top 3 most-viewed tracks for each artist using window functions.

select * from (
select artist , track , views ,
row_number() over (partition by artist order by views desc) as rn
from spotify
) a
where rn <= 3


-- 12. Write a query to find tracks where the liveness score is above the average.

select track , artist , liveness from spotify
where liveness > (select avg(liveness)
from spotify)

-- 13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.

with cte as (
	select 
		album ,  
		max(energy) as highest_energy, 
		min(energy) as lowest_energy
	from spotify
	group by album
)

select album , (highest_energy - lowest_energy) as energy_diff
from cte
order by 2 desc

