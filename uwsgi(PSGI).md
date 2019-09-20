# Setup uWSGI in web app

Please note that uWSGI(highly-performant WSGI server implementation) is not any language specific. I am taking an example for Perl language, but it is almost similar to other language (Python, Ruby,PHP etc.). I will provide the option in between for other languages too.

Sample Web App Architecture :

    1. Perl
        Code <-> Web framwork (Mojolicious, Dancer, Catalyst etc.) <-> PSGI <-> uWSGI <-> Web Server(apache, nginx) <-> Clients
    2. Python
         Code <-> Web framwork (Django, Flask etc.) <-> WSGI <-> uWSGI <-> Web Server(apache, nginx) <-> Clients
    3. Ruby
        Code <-> Web framwork (Rails etc.) <-> RACK <-> uWSGI <-> Web Server(apache, nginx) <-> Clients

Please keep in mind that PSGI/WSGI/RACK is not Yet Another web application framework. PSGI/WSGI/RACK is a specification to decouple web server environments from web application framework code. Nor is PSGI a web application API. Web application developers (end users) will not run their web applications directly using the PSGI interface, but instead are encouraged to use frameworks that support PSGI.

uWSGI is toolkit that contains PSGI/WSGI/RACK middleware, helpers and adapters to web servers. In other words, they are the implementation of PSGI/WSGI/RACK specification.

There are several ways to setup the particular architecture mentioned above.

    1. Using 'Gunicorn' or 'Green Unicorn' (inspired from Ruby 'Unicorn') for Python or using 'Plack'(inspired from Ruby 'Rack') and 'Starman'/'Starlet'/ 'Gazelle' for Perl.
    2. Using (WSGI + uWSGI) for Python or (PSGI + uWSGI) for Perl or (RACK + uWSGI) for Ruby.

All these WSGI/PSGI/RACK are plugin provided by uWSGI which extend across almost all languages.

So the question is which option is best or which has more advantage over other - I will try to explain with help of Perl but I hope it is true across other language as eveyone is inspired from each other (tongue).

    1. The PSGI 'protocol' (like WSGI) is essentially a calling convention for a subroutine. A request enters the application as a subroutine call with a hash as an argument. The application responds through the return value of the subroutine: an arrayref that contains an HTTP status code, HTTP headers and body. There is more than that, but those are the essential elements.
    2. What this means is that a process can only implement PSGI if the process contains a Perl interpreter. To achieve this, the process can be implemented in Perl or implemented in a language like C that can be loaded by the libperl.so shared library. Similarly, a process can only implement WSGI if it contains a Python interpreter.
    3. In reality the PSGI application is within the Starman process. So there are really only two parts (although both parts are multi-process containers).
    4. You say that "nginx has uWSGI directly integrated". This does not mean that a WGSI application runs within the Nginx process. It means that the WSGI application runs in a separate uwsgi process and Nginx communicates with that process through a TCP socket using the uWSGI protocol. This is essentially the same model as Nginx with Starman behind, but with the distinction that the socket connection to Starman will use the HTTP protocol:

    .----------------------.          .-----------.
    |       Starman        |          |   Nginx   |
    |                      |   HTTP   |      /    |   HTTP
    | .------------------. |<---------|   Apache  |<-------(internet)
    | | PSGI Application | |          |           |
    | '------------------' |          |           |
    '----------------------'          '-----------'

    5. The HTTP protocol has higher overhead than the uWSGI protocol, so you can get better performance by running an application server that speaks the uWSGI socket protocol and can load libperl.so to implement the PSGI interface. uWSGI can do that :

    .----------------------.           .----------.
    |        uWSGI         |           |  Nginx   |
    |                      |   uWSGI   |     /    |   HTTP
    | .------------------. |<----------|  Apache  |<-------(internet)
    | | PSGI Application | |           |          |
    | '------------------' |           |          |
    '----------------------'           '----------'

Hence it is encouraged to use uWSGI over any language specific implementation.

All few thing to note here is that-

    1. uWSGI implementation is available in almost all language (no more mod_perl or mod_python anymore(language specific))
    2. It can be implemented across CGI script also even mason too.
    3. Applicable across different Web server. So if tomorrow you want nginx instead of Apache, its 5 min of work.
    4. Scalability
    5. Speed


# How to use :

First install 'uWSGI'.

Each language has a plugin associated with it -

    1. uwsgi-plugin-psgi  -> Perl

    2. uwsgi-plugin-python3 -> Python3
       uwsgi-plugin-python  -> Python2.7

    3. uwsgi-plugin-ruby  -> Ruby

    You can install these plugin using apt-get.
    OR
    curl http://uwsgi.it/install | bash -s psgi /tmp/uwsgi


# How to Run:

    1. When running On terminal (without web server)-
        1. Python:
            uwsgi --http-socket :8080 --psgi <Application Script>
        2. Perl:
            1. uwsgi_psgi --http-socket :8080 --psgi script/my_app          OR
            2. uwsgi --plugins http,psgi --http :8080 --http-modifier1 5 --psgi script/my_app
            3. Please note that 'http-modifier' tag in option.
                1. uWSGI supports various languages and platform. When the server receives a request it has to know where to ‘route’ it.
                2. Each uWSGI plugin has an assigned number (the modifier), the perl/psgi one has the 5. So –http-modifier1 5 means “route to the psgi plugin”.
                3. ruby/rack one has the 7.
                4. lua has 6.

    2. If using socket (through Web Server)-

        Python -
            # Simple server running *wsgi*
            uwsgi --socket 127.0.0.1:8080 -w wsgi

        Perl-
            uwsgi_psgi --socket :8080 --protocol=http --psgi script/my_app

    3. You can create a config file with all the parameters and pass that file to uwsgi

    4. web server(Apache, nginx) changes needed-

        mod_proxy_uwsgi   →  apache (libapache2-mod-proxy-uwsgi)   (https://uwsgi-docs.readthedocs.io/en/latest/Apache.html)
        Nginx includes uwsgi protocol support out of the box  (https://uwsgi-docs.readthedocs.io/en/latest/Nginx.html)



# Honorable Mentions-

https://stackoverflow.com/questions/12127566/an-explanation-of-the-nginx-starman-dancer-web-stack/12134555#12134555

https://uwsgi-docs.readthedocs.io/en/latest/index.html

https://codeday.me/es/qa/20190709/1032129.html

https://metacpan.org/pod/PSGI
