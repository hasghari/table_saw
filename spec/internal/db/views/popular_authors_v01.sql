select a.id
from books b
         inner join authors a on b.author_id = a.id
group by a.id
having count(a.id) >= 5;
