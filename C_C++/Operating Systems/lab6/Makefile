app:
	gcc main.c -o app -pthread

test: app
	./app infile outfile
	diff infile outfile -s

clean:
	rm app

