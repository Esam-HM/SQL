SELECT FNAME,LNAME
FROM employee,project,works_on
WHERE pname='OperatingSystems' and pno=pnumber and ssn=essn
except
Select Fname,lname
from employee,department
where dname='Software' and dno=dnumber

select *
from employee

select pno
from employee,works_on
where essn=ssn and bdate=(select max(bdate) from employee)

select dnum, count(*)
from project
group by dnum

select pname,avg(salary)
from employee,works_on,project
where ssn=essn and pno=pnumber
group by pname
order by pname

select dnumber,dname,sex,count(*),avg(salary)
from employee,department
where dno=dnumber
group by dname,sex,dnumber

select dno
from employee
group by dno
having avg(salary)>40000

select dno,avg(salary)
from employee
where dno<>5
group by dno
having avg(salary)>40000
limit 2  offset 0

select fname,lname
from employee
order by salary desc
limit 1

select fname
from employee
where superssn is NULL


select extract(year from bdate)
from employee
--------------------------------------------------------------

--comment

select pname
from works_on , project
where pno=pnumber
group by pname
having avg(hours)>30
order by pname



----------------------------------------------------------------

create function func1(num1 numeric,num2 numeric)
returns numeric as '
declare
toplam numeric;
begin
toplam:=num1+num2;
return toplam;
end;
' language plpgsql;

create or replace function func1(num1 numeric,num2 numeric)
returns numeric as '
declare
toplam numeric;
begin
toplam:=num1+num2;
return toplam;
end;
' language plpgsql;

create or replace function func1(num1 numeric,num2 numeric,out num3 numeric)
as '
declare
begin
num3:=num1+num2;
end;
' language plpgsql;

select func1(22,63)

drop function func1(numeric,numeric)

create or replace function ortMaas(dpname department.dname%type)
returns real AS '
declare
ort numeric;
begin
select avg(salary) into ort
from employee,department
where dno=dnumber and dname=dpname;
return ort;
end;
' language plpgsql;

select ortMaas('Hardware')

drop function ortMaas(department.dname%type)

create function ornek3(out min_deptno department.dnumber%type,out max_deptno department.dnumber%type)
AS '

begin
select min(dnumber),max(dnumber) into min_deptno,max_deptno
from department;
end;
' language plpgsql;

select ornek3()


create or replace function ornek4(out calisanSayisi int)
AS '
begin
select count(*) into calisanSayisi
from employee
where dno=6;
end;
' language plpgsql;

select ornek4()

create or replace function ornek5()
returns void AS '
declare
emp_num int;
begin
select count(*) into emp_num
from employee
where dno=6;
if(emp_num<10) then
update employee set salary=salary*1.05 where dno=6;
end if;
end;
' language plpgsql;

create or replace function case_ornek(x integer)
returns text AS $$
declare
msg text;
begin
case x
when 1,2 then msg:='one or two';
when 3,4 then msg:='three or four';
else msg:='other value';
end case;
return msg;
end;
$$ language plpgsql;

select case_ornek(100)

Do $$
begin
for x in 1 .. 5 loop
raise notice 'sayi : %' , x;
end loop;
end;
$$

Do $$
begin
for x in reverse 5 .. 1 loop
raise notice 'sayi : %' , x;
end loop;
end;
$$

Do $$
begin
for x in reverse 5 .. 1 by 2 loop
raise notice 'sayi : %' , x;       --ekrana yazdırır.
end loop;
end;
$$

create or replace function increment_ornek(x integer)
returns integer As $$
begin
return x+1;
end;
$$ language plpgsql;
select increment_ornek(5)


create or replace function kosullu_zam(depname department.dname%type,deger numeric,limt integer,zam numeric)
returns void As $$
declare
ort_maas numeric;
kadin_maas numeric;
depno department.dnumber%type;
proje_sayisi integer;
begin
select dnumber into depno
from department
where dname=depname;
select avg(salary) into ort_maas
from employee
where dno=depno;
select sum(salary) into kadin_maas
from employee
where dno=depno and sex='F';
if(ort_maas<deger and kadin_maas>limt) then
update employee set salary=salary+salary*zam/100 where ssn = (select ssn,count(*) from employee, works_on
															 where essn=ssn and dno=depno
															 group by ssn
															 having count(*)>1);
end if;
end;
$$ language plpgsql;



select ssn,count(*) 
from employee, works_on,department
where essn=ssn and dno=dnumber
group by ssn
having count(*)>1

create type ornek6_record as (isim varchar(15),depname varchar(15),maas real);

drop type ornek6_record;

create or replace function ornek6(kimlik_no employee.ssn%type)
returns ornek6_record as $$
declare
	donus ornek6_record;
begin
	select fname,dname,salary into donus
	from employee,department
	where ssn=kimlik_no and dno=dnumber;
	raise notice 'ismi: % ,bolum: % , maas: % TL',donus.isim,donus.depname,donus.maas;
	return donus;
end;
$$ language plpgsql;

select ornek6('123456789')

drop function ornek6(employee.ssn%type);


create or replace function ornek_cursor(depno int)
returns void as $$
declare
	cursr cursor for select fname,lname from employee where dno=depno;
begin
for x in cursr loop
	raise info 'name-surname: % %' , x.fname,x.lname;
end loop;
end;
$$ language plpgsql;

select ornek_cursor(6);

---------------------------------------------------------

create or replace function ornek2_cursor(depno integer)
returns numeric as $$
declare
toplam_maas numeric;
cursr cursor for select salary from employee where dno=depno;
begin
toplam_maas:=0;
for satir in cursr loop
	toplam_maas:=toplam_maas+satir.salary;
end loop;
return toplam_maas;
end;
$$ language plpgsql;

select ornek2_cursor(4) with_ursor

create or replace function ornek2_without_cursor(depno integer)
returns numeric as $$
declare
toplam_maas numeric;
begin
	select sum(salary) into toplam_maas
	from employee
	where dno=depno;
	return toplam_maas;
end;
$$ language plpgsql;
select ornek2_without_cursor(4) without_cursor;

create type record_ornek7 as (isim varchar(15),soyad varchar(15),maas numeric);

create or replace function ornek7(prj_no project.pnumber%type,deger integer)
returns record_ornek7[] as $$
declare
	cur cursor for select fname,lname,salary
					from employee,works_on
					where ssn=essn and pno=prj_no;
	rec record_ornek7[];
	i int;
begin
	i:=1;
	for satir in cur loop
		if(satir.salary%deger=0) then
			rec[i]=satir;
			i:=i+1;
		end if;
	end loop;
	return rec;
end;
$$ language plpgsql;

select ornek7('2',5);     -- int small type must be in 'value'

----------exercises-----------------------

/*belirli bir ssn'e sahip employee çalıştığı projelerde
toplam saati hesaplayan fonksiyon yaz*/

create or replace function ex1(kno employee.ssn%type)
returns numeric as $$
declare
	sum_hours numeric;
begin
	select sum(hours) into sum_hours
	from works_on
	where essn=kno;
	return sum_hours;
end;
$$ language plpgsql;

select ex1('123456789');

create or replace function ex1_with_cursor(kno employee.ssn%type)
returns numeric as $$
declare
	cursr cursor for select hours
				from works_on
				where essn=kno;
	sum_hours numeric :=0;
begin
	--sum_hours:=0;
	for satir in cursr loop
		sum_hours:=sum_hours+satir.hours;
	end loop;
	return sum_hours;
end;
$$ language plpgsql;

select ex1_with_cursor('123456789');


/*belirli bir departmandaki çalışanların ort. maaşı bulan fonksiyon yaz*/

create or replace function ex2(dno employee.dno%type,out ort_maas numeric)
as $$
begin
	select avg(salary) into ort_maas
	from employee e
	where e.dno=ex2.dno;
end;
$$ language plpgsql;

select ex2('9');

create or replace function ex2_with_cursor(depno employee.dno%type, out ort_maas real)
as $$
declare
	toplam_maas numeric;
	toplam_employee int;
	cur cursor for select salary
					from employee
					where dno=depno;
begin
	toplam_maas:=0;
	toplam_employee:=0;
	for satir in cur loop
		toplam_maas:=toplam_maas+satir.salary;
		toplam_employee:=toplam_employee+1;
	end loop;
	if toplam_employee>0 then
		ort_maas=toplam_maas/toplam_employee;
	else
		raise notice 'no employees found';
	end if;
end;
$$ language plpgsql;

select ex2_with_cursor('4');

/*toplam çalışılan saatin en yüksek olduğu projeyi bulan fonksiyon yaz*/

create or replace function ex3(out max_hour integer,out prj_name varchar(30))
as $$
declare
	cur cursor for select sum(hours) top_saat,pname
					from works_on,project
					where pno=pnumber
					group by pname;
					
begin
	max_hour:=-1;
	for satir in cur loop
		if(max_hour<satir.top_saat) then
			max_hour:=satir.top_saat;
			prj_name:=satir.pname;
		end if;
	end loop;
end;
$$ language plpgsql;
drop function ex3()

select ex3();
/*
select pno,sum(hours),pname
from works_on,project
where pno=pnumber
group by pname,pno
order by sum(hours) desc
limit 1
*/

create type record_ex3 as (max_hour integer,isim varchar(30));

drop type record_ex3;

create or replace function ex3_with_record()
returns record_ex3
as $$
declare
	cur cursor for select sum(hours) top_saat,pname
					from works_on,project
					where pno=pnumber
					group by pname;
	rec record_ex3;
begin
	rec.max_hour:=-1;
	for satir in cur loop
		if(rec.max_hour<satir.top_saat) then
			rec=satir;
		end if;
	end loop;
	return rec;
end;
$$ language plpgsql;
drop function ex3_with_record();

select ex3_with_record();

/*
belirli bir proje numarasına sahip projede çalışan maaşı belirli tutar üzerinde
olan çalışanların adları,soyadları ve maaşları getiren fonksiyon bulunuz*/

create type record_ex4 as (isim varchar(20),soyisim varchar(20),maas numeric);

alter type record_ex5 rename to record_ex4;

create or replace function ex4(prj_no integer,tutar integer)
returns record_ex4[] as $$
declare
	rec record_ex4[];
	cur cursor for select fname,lname,salary
					from employee,works_on
					where essn=ssn and pno=prj_no;
	i integer :=1;
begin
	for satir in cur loop
		if satir.salary>tutar then
			rec[i]=satir;
			i:=i+1;
		end if;
	end loop;
	return rec;
end;
$$ language plpgsql;

select ex4(1,10000);


/*
belirli bir departman numarasıyla departmandaki çalışanların ad görüntüleyen raise
info ve void function kullan
*/

create or replace function ex5(dnum department.dnumber%type)
returns void as $$
declare 
	cur cursor for select fname,lname
					from employee
					where dno=dnum;
begin
	for satir in cur loop
		raise info 'isim: % %' , satir.fname,satir.lname;
	end loop;
end;
$$ language plpgsql;


select ex5('5');
