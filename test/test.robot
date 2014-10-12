*** Settings ***
Library  OperatingSystem
Library  Process
Library  String
Suite Setup  Start receiver
Suite Teardown  Stop dockers

*** Variables ***
${g_magic_message} =  kjqowiejflksjdlkf
${g_relp_port} =  20514
${g_receiver_log_dir} =  ${CURDIR}${/}receiver/logs
${g_receiver_log} =  ${g_receiver_log_dir}${/}rsyslog.log


*** Keywords ***

Start receiver
    Remove File  ${g_receiver_log}
    Create File  ${g_receiver_log}
	${rc} =  Run And Return Rc  docker build -t rsyslog-receiver receiver
    Should Be Equal As Integers  ${rc}  0
    ${g_docker_receiver_id} =  Run  docker run -d -P -v ${g_receiver_log_dir}:/rsyslog -t rsyslog-receiver
    Set Suite Variable  ${g_docker_receiver_id}

Set receiver IP ${docker_id}
    ${g_receiver_ip} =  Run  docker inspect ${docker_id} | grep IPAddress | /bin/grep -Po "\\d+\\.\\d+\\.\\d+.\\d+"
    Set Test Variable  ${g_receiver_ip}

Stop dockers
    Run  docker stop ${g_docker_receiver_id} ${g_docker_pyrelp_id} ${g_docker_pyrelp_server_id}
    Run  docker rm ${g_docker_receiver_id} ${g_docker_pyrelp_id} ${g_docker_pyrelp_server_id}

An rsyslog receiver is running
    Set receiver IP ${g_docker_receiver_id}

The reference C sender sends a message
    ${g_magic_message} =  Generate Random String
    Set Test Variable  ${g_magic_message}
    Run  cd .. && ./test/sender/send ${g_receiver_ip} ${g_relp_port} ${g_magic_message}

The relp receiver receives the message
    Sleep  2 sec
    ${rc} =  Run And Return Rc  grep ${g_magic_message} ${g_receiver_log}
    Should Be Equal As Integers  ${rc}  0

Pyrelp is installed on a clean machine
    Copy File  ${CURDIR}${/}../dist/pyrelp*.tar.gz  clean-machine/pyrelp.tar.gz
    ${rc} =  Run And Return Rc  docker build -t clean-machine clean-machine
    Should Be Equal As Integers  ${rc}  0
    Remove File  clean-machine/pyrelp*.tar.gz

The pyrelp client sends a message
    ${g_magic_message} =  Generate Random String
    Set Test Variable  ${g_magic_message}
    ${rc}  ${g_docker_pyrelp_id} =  Run And Return Rc And Output  docker run -d -t clean-machine bash -c "pyrelp ${g_receiver_ip} ${g_relp_port} ${g_magic_message}"
    Should Be Equal As Integers  ${rc}  0
    Set Suite Variable  ${g_docker_pyrelp_id}

The reference C receiver is running
    Set Test Variable  ${g_receiver_ip}  127.0.0.1
    Start Process  ./test/receiver/receive  ${g_relp_port}  cwd=${CURDIR}${/}..

A pyrelp receiver is running
    ${receiver} =  Get File  ${CURDIR}${/}receiver/receive.py
    ${rc}  ${g_docker_pyrelp_server_id} =  Run And Return Rc And Output  docker run -d -v ${g_receiver_log_dir}:/rsyslog -t clean-machine python -c "${receiver}"
    Should Be Equal As Integers  ${rc}  0
    Set Suite Variable  ${g_docker_pyrelp_server_id}
    Set receiver IP ${g_docker_pyrelp_server_id}


*** Test Cases ***
Reference C sender can send a RELP message
    Given an rsyslog receiver is running
    When the reference C sender sends a message
    Then the relp receiver receives the message

Reference C receiver can receive a RELP message
    Given the reference C receiver is running
    When the reference C sender sends a message
    Then the relp receiver receives the message

Pyrelp can be installed and send a RELP message
    Given an rsyslog receiver is running
    When pyrelp is installed on a clean machine
    And the pyrelp client sends a message
    Then the relp receiver receives the message

Pyrelp server can receive a RELP message
    Given pyrelp is installed on a clean machine
    And a pyrelp receiver is running
    When the pyrelp client sends a message
    Then the relp receiver receives the message

