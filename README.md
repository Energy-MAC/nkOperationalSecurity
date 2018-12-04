# n-k Operational Security Problem
[![Build Status](https://travis-ci.org/Energy-MAC/nkOperationalSecurity.svg?branch=master)](https://travis-ci.org/Energy-MAC/nkOperationalSecurity) [![Join the chat at https://gitter.im/Energy-MAC/nkOperationalSecurity](https://badges.gitter.im/Energy-MAC/nkOperationalSecurity.svg)](https://gitter.im/Energy-MAC/nkOperationalSecurity?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

The $N-k$ problem is a Mixed-Integer Non-Linear Program (MINLP), usually intractable, since the combinatorial combinations of binary variables representing component fails (even for small values of $k$) in addition to the non-linear modeling of power flow physics, make this problem a non convex one.

Although in many cases the use of linear approximations in power systems is sufficient, when trying to model possible cascading effects such models are not appropriate.

In this repository we explore several formulations to solve the problem.

## Solutions for 14 Bus System

| Big M  | Sol   | Gap   | time (ms)   | N sols |
|--------|-------|-------|------------|--------|
| 0.95   | 2     | 0     |    35    |  3      |
| 0.9    |   3  |   0   |    39.7    |    2    |
| 0.85   |  4   | 0   |   59.6     |   3  |
| 0.8    | 4   | 0 |  66.9      |    3   |
| 0.75   |  5 |  0    |       79.3     |    4    |
| 0.7    |   6   |  0     |     80.5      |  3    |


| lambda_i | Sol   | Gap   | time (ms)   | N sols |
|--------|-------|-------|------------|--------|
| 0.95   | 2     | 0     |    88.2    |  3      |
| 0.9    |  3   |  0   |   70.9  |     3   |
| 0.85   |   4  | 0   |    121    |   4  |
| 0.8    |   4 | 0 |   92.5     |    4   |
| 0.75   | 5  |   0  |     105       |     5   |
| 0.7    |  6    |  0     |   160        |  3    |


| NL     | Sol   | round | Term Code       | time (ms)  |
|--------|-------|-------|------------|--------|
| 0.95   | 2.96  | 3     | optimal     | 55.2  |
| 0.9    | 4.82   | 5     | optimal    | 62.1   |
| 0.85   | 4.86  | 5     | optimal    | 83.2   |
| 0.8    | 4.91  | 5    | optimal    | 102   |
| 0.75   | 8.93  | 9    | optimal    | 360    |
| 0.7    | 9.93  | 10    | optimal | 98.0   |


## Solutions for 118 Bus System

| Big M  | Sol   | Gap   | time (s)   | N sols |
|--------|-------|-------|------------|--------|
| 0.95   | 2     | 0     | 7.2        | 2      |
| 0.9    | 4     | 0     | 251        | 5      |
| 0.85   | 5     | 40%   | 3600       | 4      |
| 0.8    | 7     | 57.14% | 3600       | 5      |
| 0.75   | 9     | 66.67%    | 3600       | 5      |
| 0.7    | 11    | 72.72%| 3600       | 4      |


| lambda_i | Sol   | Gap   | time (s)   | N sols |
|--------|-------|-------|------------|--------|
| 0.95   | 2     | 0     | 20.2       |  3      |
| 0.9    | 4     | 0     | 209        |   3     |
| 0.85   | 5     | 40 %   | 3600       |  8    |
| 0.8    | 7     |57.14%  | 3600       |   8    |
| 0.75   | 9    |   66.67%    |   3600         |    8    |
| 0.7    |   12    |   66.67%    |    3600        |   7     |


| NL     | Sol   | round | Term Code       | time  (s) |
|--------|-------|-------|------------|--------|
| 0.95   | 3.77  | 4     | optimal     | 1.04   |
| 0.9    | 3.97  | 4     | optimal    | 1.13   |
| 0.85   | 6.91  | 7     | optimal    | 1.21   |
| 0.8    | 11.3  | 11    | optimal    | 1.16   |
| 0.75   | 14.9  | 15    | optimal    | 1.2    |
| 0.7    | 16.23 | 16    | acceptable | 10.6   |
