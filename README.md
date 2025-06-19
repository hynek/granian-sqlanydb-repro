# Repro of Granian x SQL Anywhere shutdown problems

Needs Docker, [Just](https://just.systems/man/en/), and curl. Just can be
omitted if you're OK with copy-pasting commandlines.

For licensing reasons, it also needs <https://help.sap.com/docs/SUPPORT_CONTENT/sqlany/3362971128.html>. Download it for Linux and unpack the archive into this directory (it should be `client17011`).

## MRE

### Happy path

1. `just docker-run`
2. `just req`
3. `just docker-stop`

Gets you:

```
[INFO] Spawning worker-1 with PID: 8
[INFO] Started worker-1
[INFO] Started worker-1 runtime-1
[INFO] Shutting down granian
[INFO] Stopping worker-1
[INFO] Stopping worker-1 runtime-1
```

Weirdly, the atexit handler is **not** run here too. This works for me in prod, but I don't have the headspace to investigate further. But maybe it's a clue??


### Sad path

1. `just docker-run`
2. `just req-break-it`
3. `just docker-stop`

Gets you:

```
[INFO] Spawning worker-1 with PID: 8
[INFO] Started worker-1
[INFO] Started worker-1 runtime-1
[INFO] Shutting down granian
error: Recipe `docker-run` failed on line 47 with exit code 137
```

With a significant delay between the last two lines, because Docker waits for the graceful timeout and then SIGKILLs it.
