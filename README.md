# n-k Operational Security Problem
[![Build Status](https://travis-ci.org/Energy-MAC/nkOperationalSecurity.svg?branch=master)](https://travis-ci.org/Energy-MAC/nkOperationalSecurity) [![Join the chat at https://gitter.im/Energy-MAC/nkOperationalSecurity](https://badges.gitter.im/Energy-MAC/nkOperationalSecurity.svg)](https://gitter.im/Energy-MAC/nkOperationalSecurity?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

The $N-k$ problem is a Mixed-Integer Non-Linear Program (MINLP), usually intractable, since the combinatorial combinations of binary variables representing component fails (even for small values of $k$) in addition to the non-linear modeling of power flow physics, make this problem a non convex one.

Although in many cases the use of linear approximations in power systems is sufficient, when trying to model possible cascading effects such models are not appropriate.

In this repository we explore several formulations to solve the problem.