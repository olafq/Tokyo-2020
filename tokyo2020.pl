% 1 Modelar los atletas, las disciplinas, en cuál compite cada uno, las medallas y los eventos minimizando la repetición de lógica
% y respetando las consideraciones mencionadas. Dar un par de ejemplos incluyendo disciplinas individuales y por equipos.

%atleta(Nombre,Edad,Pais).
%compiteEn(Nombre,NombreDisciplina).
%disciplina(NombreDisciplina,individual).
%disciplina(NombreDisciplina,equipo).
%medalla(oro,Disciplina,Ganader).
%evento(Disciplina,Ronda,Participantes).
%EJEMPLO
atleta(olaf,21,argentina).
compiteEn(olaf, natacion400MetrosMasculino).
disciplina(natacion400MetrosMasculino,individual).
disciplina(voleyMasculino,equipo).
medalla(oro,voleyMasculino,Pais).
medalla(plata,natacion400MetrosMasculino,Ganador).
evento(natacion400MetrosMasculino,1,[olaf,nicolas]).
evento(voleyMasculino,faseDeGrupos,[argentina,brasil]).

%2 vinoAPasear/1: se cumple para un atleta que no compite en ninguna disciplina.
vinoAPasear(Atleta) :-
    atleta(Atleta,_,_),
    not(compiteEn(Atleta,_)).

%3 medallasDelPais/3: nos dice en qué disciplinas ganaron medallas cuáles países.
% Recordar que un país puede obtener medallas en disciplinas por equipo o también a través de atletas que lo representen.
medallasDelPais(Disciplina,Medalla,Pais) :-
    medalla(Medalla,Disciplina,Ganador),
    atleta(Ganador,_,Pais).
medallasDelPais(Disciplina,Medalla,Pais) :-
    medalla(Medalla,Disciplina,Ganader),
    disciplina(Disciplina,Tipo),
    paisDelGanador(Tipo,Ganader,Pais).

paisDelGanador(individual,Ganador,Pais) :-
    atleta(Ganador,_,Pais).
paisDelGanador(equipo,Pais,Pais). %Si es en equipo  el pais ganador es el mismo pais.

%4 participoEn/3: relaciona en qué rondas y disciplinas se desempeñó un atleta. 
%Para disciplinas individuales, dependerá de en qué eventos estuvo (puede haber participado en las rondas 1 y 2, por ejemplo, pero no haber pasado a la ronda 3); 
%para disciplinas en equipo, se considera que los atletas de la disciplina participan siempre que su país participe en la ronda. 
%Por ejemplo, si argentina participa en octavosDeFinal de voleyMasculino, todos los atletas argentinos que se desempeñen en voleyMasculino participan en esa ronda.
participoEn(Ronda,Disciplina,Atleta) :-
    disciplina(Disciplina,Tipo),
    tipoDeParticipante(Tipo,Atleta,Participante),
    evento(Disciplina,Ronda,Participantes),
    member(Participante, Participantes).

tipoDeParticipante(individual,Atleta,Atleta).
tipoDeParticipante(equipo,Atleta,Pais) :-
    atleta(Atleta,_,Pais).

%5 dominio/2: se cumple para un país y una disciplina si todas las medallas en esa disciplina fueron entregadas a atletas del mismo país.
% Naturalmente, esto sólo puede ocurrir en disciplinas individuales.
pais(Pais) :-
 distinct(atleta(_,_,Pais)).
 
dominio(Pais,Disciplina) :-
    pais(Pais),
   disciplina(Disciplina,individual),
   forall(medalla(Medalla,Disciplina,_),medallasDelPais(Disciplina,Medalla,Pais)).

%6 medallaRapida/1: es verdadero para las disciplinas cuyas medallas se definieron en un evento a ronda única.
medallaRapida(Disciplina) :-
    disciplina(Disciplina,_),
    evento(Disciplina,Ronda,_),
    not(tieneOtraRonda(Disciplina,Ronda)).

tieneOtraRonda(Disciplina,Ronda) :-
    evento(Disciplina,OtraRonda,_),
    OtraRonda \= Ronda.

%7 noEsElFuerte/2: relaciona a un país con las disciplinas en las que no participó o sólo participó en una ronda inicial. 
%En los casos de disciplinas por equipos, esa ronda es faseDeGrupos; en los casos de disciplinas individuales, es la ronda 1.

noEsElFuerte(Pais,Disciplina) :-
    pais(Pais),
    disciplina(Disciplina,_),
    leFueMal(Pais,Disciplina).

leFueMal(Pais,Disciplina) :-
   not(paisParticipoEn(Pais,Disciplina,_)).

leFueMal(Pais,Disciplina) :-
    not(participoEnRondaNoInicial(Pais,Disciplina)).

paisParticipoEn(Pais,Disciplina,Ronda) :-
    atleta(Atleta,_,Pais),
    participoEn(Ronda,Disciplina,Atleta).

participoEnRondaNoInicial(Pais,Disciplina) :-
    paisParticipoEn(Pais,Disciplina,Ronda),
    disciplina(Disciplina,Tipo),
    not(rondaInicialParaTipos(Tipo,Ronda)).

rondaInicialParaTipos(individual,1).
rondaInicialParaTipos(individual,faseDeGrupos).

%8 medallasEfectivas/2: nos dice la cuenta final de medallas de cada país.
% No es simplemente la suma de medallas, sino que cada una vale distinto: las de oro suman 3, las de plata 2, y las de bronce 1.

medallasEfectivas(Pais,PuntosTotales) :-
    findall(PuntoMedalla, puntoDeMedallaGanada(PuntoMedalla,Pais), PuntosDeMedallas),
    sumlist(PuntosDeMedallas, PuntosTotales).

puntoDeMedallaGanada(PuntoMedalla,Pais):-
 medallasDelPais(_,Medalla,Pais),
 tipoDeMedalla(Medalla,PuntoMedalla).

tipoDeMedalla(oro,3).
tipoDeMedalla(plata,2).
tipoDeMedalla(bronce,1).

%9 laEspecialidad/1: se cumple para los atletas que no vinieron a pasear y obtuvieron medalla de oro o plata en todas las disciplinas en las que participaron.
laEspecialidad(Atleta) :-
    atleta(Atleta,_,_),
    forall(participoEn(Atleta,_,Disciplina),ganoBuenaMedalla(Atleta,Disciplina)).

ganoBuenaMedalla(Atleta,Disciplina) :-
    medalla(Medalla,Disciplina,Ganader),
    disciplina(Disciplina,Tipo),
    tipoDeParticipante(Tipo,Atleta,Ganader),
    medallaBuena(Medalla).

medallaBuena(oro).
 medallaBuena(plata).

  
    
    


