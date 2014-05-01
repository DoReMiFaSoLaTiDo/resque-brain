# resque-brain: a better resque-web

resque-web, which comes with Resque has a few problems:

- the UI is not helpful
  - what deserves my attention in Resque right now?
  - how do I deal with a failed job?
  - replaying a failed job is counterintuitive
  - not responsive/mobile-friendly
  - cannot kill stuck workers
- It can only show information about one Resque
  - sophisticated platforms have several Resques, but want centralized monitoring
- No actual monitoring
  - how many failed jobs is "too many"?
  - how long is a worker allowed to run before it's "stuck"?
  - how many unprocessed jobs is "too many"?

resque-brain changes that.  resque-brain is useful if:

- you want monitoring of potential or real problems
- your jobs are important, and failures indicate a problem or bug
- you have more than one resque in operation
- you may need this information away from a desktop computer and large monitor

## This biggest underlying problem

Resque's design is hard-coded to force each Ruby VM to have exactly one Resque.  No Ruby VM can access more than one Resque by
just using Resque's API, because Resque shares its connection to redis as a global variable, and it's used by all parts of
Resque.

Enter `Resque::DataStore`.

This class encapsulates *all* Redis access by Resque.  Users of the class will not need to know the keys or data structures that
Resque uses inside Redis.  More importantly, this class can be given any instance of `Redis`, so that multiple instances can
exist in the same VM to access data about different Resques.

# UI

![Overview](https://www.evernote.com/shard/s71/sh/393c9f46-8d55-42c3-bb40-ef8c3a1799cb/d40d83e1793239fc4e0df9edf793805f/deep/0/ResqueBrain.png)

![Jobs Running](https://www.evernote.com/shard/s71/sh/c8f014f0-220c-437e-ae9b-a04ae1fbf075/7d6108ee43e32052ba22a326751ffcf1/deep/0/ResqueBrain.png)

![Killing Worker](https://www.evernote.com/shard/s71/sh/890e9060-ed2f-4a9c-ac87-6c26adeb2cd6/3344b1cca6ac698b70376ac98fa56373/deep/0/ResqueBrain.png)

![Jobs Waiting](https://www.evernote.com/shard/s71/sh/af317bd1-1008-49a7-896e-dbb7ed3e268a/dbe3572974b948cf35ba85abccd3f8ba/deep/0/ResqueBrain.png)

![Failed Queue](https://www.evernote.com/shard/s71/sh/392fa832-d624-4555-b0bf-234a938fb502/3a8d37b12e7e350e75289bf3859a2d75/deep/0/ResqueBrain.png)

![Exception View](https://www.evernote.com/shard/s71/sh/db773b9f-863d-4e63-9f42-f4fe0044b6e0/5b05e134319b90e5921b619de34d01db/deep/0/ResqueBrain.png)

![Mobile View](https://www.evernote.com/shard/s71/sh/83a464b0-ed1a-410d-9929-da39e7dcca75/5867da4b8a4ff3087c718e8ed45d74bf/deep/0/ResqueBrain.png)

# Notes


What do we want out of resque monitoring?

- Monitor multiple instances
- Automated notifications
  - conditions
    - too many failed jobs
    - queues have too many jobs unprocessed
    - workers in progress for too long
  - channels
    - email
    - web hook
    - status page
  - stats
    - size of queues
    - job processing time (if possible)
- visual overview
  - failed jobs
  - jobs running/workers working
  - jobs waiting
- remediate problems
  - retry jobs
  - kill jobs
  - kill workers

# Overview

* Jobs failed - `num_failed`
* Jobs running -  `worker_ids.map(&:get_worker_payload).compact`
* Too long - introspect Worker.working
* Jobs waiting - Resque.queues.each &:peek

# In Progress

* Worker.working.each
  - queue = Worker#job[:queue]
  - job class = Worker#job[:payload]
  - job args = Worker#job[:payload]
  - runtime = Worker#job[:run_at]
  - kill worker - Worker#unregister_worker

# Waiting

Resque>queues + peek

# Failed

- failed jobs - Resque::Failure
- link to source - with configured git repo, could use convention.
- google search - simple link
- retry, clear, retry & clear - see resque-web, but must be safer than what that app does
- email - simple mailer or even copy&paste link


# Accessing multiple resques

* We can't use pretty  much any code in Redsque as it stands
- Ideally, we'd have an interface that represents all Redis operations that Resque uses, and that interface
  would take a redis connection in the constructor.
