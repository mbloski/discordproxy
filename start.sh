cd src
while true
do
	ruby proxy.rb
	echo "proxy died, respawning" >&2
done
