# docker-gc

This is a shell function I use to clean up Docker's mess (stopped containers and dangling images) when my hard drive starts to get full.

Copy and paste the functions into your .bashrc or .zshrc (or source the script) to have them available in your shell.  You'll have to have [jq][] installed on your system (as well as socat and curl, but you most likely already have those installed).

## Why

The two commands most people suggest running to clean up Docker images and containers are `docker rm $(docker ps -a -q)` and `docker rmi $(docker images -f "dangling=true" -q)`.

The danger is in the first command (`docker rm`).  This command attempts deleting *all* containers, but will in effect only delete all *stopped* containers because `docker rm` will refuse to delete running containers.  The danger here that is not mentioned in most places I see copying and pasting it around is that [data-only containers][data-only-containers] tend to get deleted with this command, because data-only containers are usually stopped containers (typically of the form `docker run busybox true`; the `true` command exits immediately).

Because I name my data-only containers with the word "data" in the name somewhere, I wrote this script to explicitly exclude them.

## Future solutions

There was at one point a [feature request to be able to "pin" certain containers][docker-pin] to prevent them from being deleted even if stopped, but the [PR was rejected][docker-pin-rejected].

If [`docker ps --filter`][docker-ps-filter] ever gets the ability to accept name patterns, this script can be replaced.

[jq]: http://stedolan.github.io/jq/
[data-only-containers]: http://www.tech-d.net/2013/12/16/persistent-volumes-with-docker-container-as-volume-pattern/
[docker-pin]: https://github.com/docker/docker/pull/7523
[docker-pin-rejected]: https://github.com/docker/docker/pull/7523#issuecomment-59592874
[docker-ps-filter]: https://docs.docker.com/reference/commandline/cli/#filtering_1

