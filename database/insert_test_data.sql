set timezone to '-4:30';

select * from sign_up('maedeh', '123123', '09119700343', 'Rasht', 'Maedeh', 'Norouzi', '2002-07-06'::date, 'Maed', '25814442220', true);

select * from get_logged_in_username();
select * from login('maedeh@voovle.com', '123123');