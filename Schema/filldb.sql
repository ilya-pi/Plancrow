
insert into dict_currency (CURRENCY_CODE,CURRENCY_SYMBOL,CURRENCY_NAME) values ('EUR','€','Euro'),  ('USD','$','U.S. Dollar');

insert into company (NAME, URL_EXT, CURRENCY_ID, NOTIFF_DAY) values ('ClockHog','clockhog',1,5);

insert into app_user (login,pwd,first_name,second_name,primary_email) values
('mkorotkov','123','Maxim','Korotkov','korotkov.maxim@gmail.com'),
('ipimenov','123','Ilya','Pimenov','ilya.pimenov@gmail.com'),
('tkalapun','123','Taras','Kalapun','t.kalapun@gmail.com');

insert into userlink (C_ID,U_ID,AMND_USER,EMAIL,ROLE) values
(1,1,1,'korotkov.maxim@gmail.com','PM'),
(1,2,1,'ilya.pimenov@gmail.com','ADM'),
(1,3,1,'t.kalapun@gmail.com','EXEC');


insert into customer (C_ID,AMND_USER,NAME) values (1,1,'Mega-Customer');
insert into project (C_ID,CUSTOMER_ID,AMND_DATE,AMND_USER,NAME,ESTIMATE) values
(1,1,SYSDATE(),1,'Project 1',1000*60*60*24*100);

insert into project_phase (AMND_USER,PROJECT_ID,PARENT_ID,NAME) values
(1,1,null,'Phase 1'),
(1,1,null,'Phase 2'),
(1,1,1,'Phase 1 subphase 1'),
(1,1,1,'Phase 1 subphase 2');

insert into task (AMND_USER,PROJECT_PHASE_ID,NAME,ESTIMATE,STATUS) values
(1,3,'Task A',1000*60*60*24*2,'A'),
(1,3,'Task B',1000*60*60*24*5,'A'),
(1,4,'Task C',1000*60*60*24*1,'A'),
(1,2,'Task D',1000*60*60*24*10,'A');


insert into assignment (AMND_USER,PROJECT_ID,USERLINK_ID,TASK_ID,TYPE) values
(1,1,1,null,'PM'),
(1,1,1,null,'U'),
(1,1,1,1,'U');

insert into timing (amnd_user,task_id,value,timing_date,userlink_id) values
(1,1,1000*60*60,SYSDATE(),1),
(1,2,1000*60*60,SYSDATE(),1),
(2,1,1000*60*60*2,SYSDATE(),2);

