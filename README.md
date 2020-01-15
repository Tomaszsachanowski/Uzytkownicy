# Uzytkownicy
## Celem projektu jest zapoznanie się ze sposobem tworzenia kont i konfiguracją środowiska pracy użytkowników. Jest to zadanie wspólne dla wszystkich uczestników kursu.
## Treść:
Napisać skrypt do zakładania, kasowania i modyfikowania użytkowników, który będzie także konfigu-
rował ich środowisko pracy. Powinna istnieć możliwość:

* zakładania użytkownika z wyborem przy tym wolnego uid;
* opcjonalnie — wybór uid ze sprawdzeniem, czy jakiś istniejący użytkownik nie ma już takiego;
* generowania losowego hasła;
* kopiowania standardowych plików kropkowych z zadanego katalogu do domowego;
* zapisywanie danych użytkownika (login, uid, hasło)
* modyfikacji grup, do których należy użytkownik oraz innych danych dotyczących użytkownika
* kasowania kont użytkowników.

## Skrypt powinien pracować w dwóch trybach:
* wsadowym, w którym wszystkie dane podawane będą jako parametry linii poleceń,

* interakcyjnym, w którym będzie się komunikował z administratorem za pomocą ładnego okienko-
wego interfejsu i umożliwiał wybór grup, powłok, użytkowników do skasowania, itp. przy pomocy
przewijanych list menu.

## Uwaga! Przy tworzeniu interfejsu należy skorzystać z perlowego modułu Tk.

# Sposób użycia
komenda `sudo perl main.pl`

Główne okno zkłada sie z 3 pozycji w pasku narzędzi:
* Exit
* User
* Group

1. `Exit` pozwala na poprawne amknięcie okna
2. `User`  składa się na możliwość:  
    *  `Add user` dodania nowego użytkownika  
    * `Remove user` usunięcia użytkownika i modyfikacji danych (login, gid, uid)  

`Add user` odbywa się po przez wpisanie wymaganych danych w wolne pola tekstowe. Żadne z pól tekstowych nie może być puste. Login musi być unikalny jak i Uid. Hasło jest generownane losowo automatycznie, możliwe jest zastąpienie własną kombinacją.
Uid jest wybrany jako pierwsze wolny kod z przedziału 1000, 60000, gdzie żaden użytkownik nie posiada takie samego. Jest możliwość użycia własnego numeru Uid, ale program sprawdza powyższe wymagania. Gid domyślnie jest wybrany na 1001 jest możliwośc wyboru innego któ©y nalezy do przedziału 1000 60000. Jeśli podany gid nie istnieje to zostaje stworzona grupa pod nazwa login i numerze gid. Informacje o użytkowniku będą zapisane w pliku `/var/uzytkownicy`.

W sytucaji nie powodzeń label warninig informuje co jest przyczyną niemożliwości dodania nowego użytkownika. W przypdaku pozytywnym label warning róœniez informuje o pozytywnym zatwierdzeniu.

`Remove user` odbywa nie przez wybór naszego użytkownika z pośród loginów znajdujących się w lewym ListBox. Po wyborze użytkownika następuje uzupełnienie danych po prawej stronie. Aby dokonać usunięcia należy kliknąć guzik `Delete`.  
W celu modyfikacji danych użytkownika należy podać nowe dane w odpowiednie róbryki. Jest możliwość zmiany nazwy loginu, uid i gid. Dane te muszą spełać te same warunki jak podczas dodawania.

2. `Group` składa się z możliwości:
    *  `Add groups` dodania nowej grupy do użytkownika
    * `Remove groups` usunięcia grupy uzytkownikowi.  

`Add groups` odbywa się przez wybór uzytkownia z lewego ListBox oraz groupy z prawego. Następnie użycie guzika `Add to group`. Grupy które pojawiają sie z prawej strony są to grupy już stowrzone które mają gid należący do przedziału 1000 60000.  

`Remove groups` odbywa się przez wybór użytkownika z lewego ListBox po czym w prawym ListBox pojawiają się grupy wybranego użytkownika. Należy wybrać grupę, którą planujemy usunąć i nacisnąć guzik `Remove group`.