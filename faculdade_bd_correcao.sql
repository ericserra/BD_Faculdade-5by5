use Faculdade_BD_Corrigido
create table Curso
(
	codigo int not null primary key,
	nome varchar(30) not null,
	sigla varchar(10) not null,
);
create table Professor
(
	codigo int not null primary key,
	CPF varchar(11) not null unique,
	nome varchar(50) not null,
);
create table Aluno
(
	ra varchar(11) not null primary key,
	CPF varchar(11) not null unique,
	nome varchar(50) not null,
	Cod_Curso int not null,
	constraint fk_cod_curso foreign key(Cod_Curso) references Curso(codigo)
);
create table Disciplina
(
	codigo int not null primary key,
	nome varchar(50) not null,
	sigla varchar(10) not null,
	carga_horaria int not null,
	cod_curso int not null,
	constraint fk_curso_disciplina foreign key(cod_curso) references Curso(codigo)
);
create table  Curso_Professor
(
	cod_professor int not null,
	cod_curso int not null,
	constraint fk_curso foreign key (cod_curso) references Curso(codigo),
	constraint fk_professor foreign key (cod_professor) references Professor(codigo)
);
create table Disciplina_Professor
(
	cod_disciplina int not null,
	cod_professor int not null,
	ano date not null,
	semestre int not null,
	constraint fk_cod_disc foreign key(cod_disciplina) references Disciplina(codigo),
	constraint fk_cod_prof foreign key(cod_professor) references Professor(codigo),
);
create table Matricula
(
	cod_disciplina int not null,
	ra varchar(11) not null,
	ano date not null,
	semestre int not null,
	faltas int not null,
	sub float null,
	media float null,
	prova_1 float null,
	prova_2 float null,
	status_aluno varchar(15) null,
	constraint fk_aluno foreign key(ra) references Aluno(ra),
	constraint fk_disc_cod foreign key(cod_disciplina) references Disciplina(codigo)
);

insert into Curso values(1,'Desenvolvimento de Sistemas', 'DS');
insert into Curso values(2,'Ciencia de Dados', 'CD');

select * from Curso

insert into Professor values(1, '12345678911', 'Felipe Pestana');
insert into Professor values(2, '12345678912', 'Fabio Papini');
insert into Professor values(3, '12345678913', 'Malara');
insert into Professor values(4, '12345678914', 'Douglas');

select * from Professor 

insert into Curso_Professor values(1, 1)
insert into Curso_Professor values(2, 2)
insert into Curso_Professor values(3, 1)
insert into Curso_Professor values(4, 2)

select * from Curso_Professor

insert into Disciplina values (1, 'Algoritmos e Lógica da Programação', 'ALP', 150, 1)
insert into Disciplina values (2, 'Estrutura de Dados', 'EDD', 120, 1)
insert into Disciplina values (3, 'Analise de Dados', 'ADD', 150, 2)
insert into Disciplina values (4, 'Carga de Dados', 'CDD', 120, 2)

select * from Disciplina

insert into Disciplina_Professor values(1, 1, '2020', 1)
insert into Disciplina_Professor values(2, 2, '2020', 1)
insert into Disciplina_Professor values(3, 3, '2019', 1)
insert into Disciplina_Professor values(4, 4, '2019', 1)

select * from Disciplina_Professor

insert into Aluno values ('12345678910', '10987654321', 'Eric Serra', 1)
insert into Aluno values ('12345678911', '10987654322', 'Fernando', 2)
insert into Aluno values ('12345678912', '10987654323', 'José Fernandez', 1)
insert into Aluno values ('12345678913', '10987654324', 'Eric Carr', 2)

select * from Aluno

insert into Matricula(cod_disciplina, ra, ano, semestre, faltas, sub, prova_1, prova_2) values (1,'12345678910', '2020', 1, 5, 0,7,8);
insert into Matricula(cod_disciplina, ra, ano, semestre, faltas, sub, prova_1, prova_2) values (1,'12345678911', '2019', 2, 12,7,3,6);
insert into Matricula(cod_disciplina, ra, ano, semestre, faltas, sub, prova_1, prova_2) values (1,'12345678912', '2020', 3, 29,2,5,3);
insert into Matricula(cod_disciplina, ra, ano, semestre, faltas, sub, prova_1, prova_2) values (1,'12345678913', '2021', 4, 59,0,9,7);
select * from Matricula

CREATE TRIGGER Calcula_Matricula
ON Matricula
FOR INSERT
AS
Begin
	DECLARE
	@P1 FLOAT,
	@P2 FLOAT,
	@P_SUB FLOAT,
	@MEDIA FLOAT,
	@FALTA FLOAT,
	@Carga_H FLOAT,
	@Situacao VARCHAR(25),
	@Semestre int,
	@id_disc int,
	@RA varchar(20)
	SELECT @RA = ra, @FALTA = faltas, @P1 = prova_1, @P2 = prova_2, @P_SUB = sub, @id_disc = cod_disciplina, @Semestre = semestre 
	FROM INSERTED
	SELECT @Carga_H = d.carga_horaria 
	from DISCIPLINA D WHERE D.codigo = @id_disc
	UPDATE Matricula SET 
	Matricula.faltas =  100 - ((@FALTA/@Carga_H)*100),
	Matricula.media = CASE WHEN (@P1 + @P2)/2 < 6 THEN 
	CASE WHEN @P2>@P1 THEN (@P_SUB + @P2)/2
	ELSE (@P_SUB + @P1)/2 END
	ELSE (@P1 + @P2) / 2 END
	WHERE Matricula.ra = @RA AND Matricula.cod_disciplina = @id_disc AND Matricula.semestre  = @Semestre
	UPDATE Matricula SET 
	Matricula.status_aluno = CASE WHEN Matricula.faltas < 75 THEN 'REPROVADO (FALTA)' 
	WHEN Matricula.media < 6 THEN 'REPROVADO(NOTA)'
	ELSE 'APROVADO' END
	WHERE Matricula.ra = @RA AND Matricula.cod_disciplina = @id_disc AND Matricula.semestre  = @Semestre
END

select a.Nome as Alunos, m.prova_1 as 'Nota 1', m.prova_2 as 'Nota 2', m.Sub as 'Substitutiva', m.Media
from Disciplina d
Join Matricula m on d.Codigo = m.Cod_disciplina
join Aluno a on a.RA = m.RA
where d.Sigla = 'ALP' and m.Ano = '2020';

select a.Nome as Alunos, m.prova_1 as 'Nota 1', m.prova_2 as 'Nota 2', m.Sub as 'Substitutiva', m.Media, d.Nome as 'Nome da Disciplina', d.Sigla, m.faltas as 'Faltas'
from Aluno a
join Matricula m on m.RA = a.RA
join Disciplina d on d.Codigo = m.Cod_disciplina
where a.RA = '12345678911' and m.Semestre = '2' and m.Ano = '2019'

select a.Nome as 'Alunos', m.Media, d.Nome as 'Disciplinas', m.faltas
from Curso c
join Aluno a on a.Cod_curso = c.Codigo
join Matricula m on m.RA = a.RA
join Disciplina d on d.Codigo = m.Cod_disciplina
where c.Sigla = 'DS' and m.Ano = '2020' and m.Status_aluno = 'Reprovado'

select distinct p.Nome,c.Nome, count(dp.Cod_disciplina) as 'Total de disciplinas'
from Professor p
join Curso_Professor cp on cp.Cod_Professor = p.Codigo
join Disciplina_Professor dp on dp.Cod_Professor = p.Codigo
join Curso c on c.Codigo = cp.Cod_Curso
where p.CPF = '12345678911'
group by p.nome, c.Nome
order by p.Nome, c.Nome