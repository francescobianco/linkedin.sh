
push:
	@git add .
	@git commit -am "New release!" || true
	@git push

pull:
	@git pull

test:
	@echo "No tests to run!"

test-auth:
	@bash tests/auth-test.sh

test-info:
	@bash tests/info-test.sh

test-post:
	@bash tests/post-test.sh
