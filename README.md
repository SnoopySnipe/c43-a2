# CSCC43 Fall 2020 - Assignment 2

## Environment Setup

Execute the following script as ``root`` to setup your ``PostgreSQL`` workspace. This script will both install ``PostgreSQL`` if it is not already installed as well as set up all credentials necessary for the sequential marking script.

```
$ sudo bash setup.sh
```

If necessary, see ``env.sh`` to see the connection credentials.

```
$ cat env.sh
```

## Program Setup

1. Drag your submission under ``src/com/kthisiscvpv`` named as ``Assignment2.java``. You might need to make some slight modifications to make the program compile (eg. change your ``package`` declaration, change the encapsulation of the ``Assignment2()`` constructor and ``Connection connection`` variable to ``public``).
2. Compile the program ``App.java`` as an executable file named ``driver.jar``.

## Marking Scheme

Student submissions were marked using the marking scheme identified under ``test-cases.md``.

Execute the following script to run the automarker on your ``driver.jar`` submission.

```
$ bash run_test.sh "mark.txt"
```

This will generate a ``mark.txt`` file in the relative directory showing the result of all test cases passed.

**Notice:** The weighting listed inside ``test-cases.md`` is arbitrary. The grade you recieve on ``MarkUs`` may have a different weighting.

**Notice:** All student submissions are ran with a ``timeout of 5 seconds`` before their process is killed.
