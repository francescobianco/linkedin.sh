
push:
	@git add .
	@git commit -am "New release!" || true
	@git push

pull:
	@git pull

test:
	@bash calendar-script.sh

test-auth:
	@bash tests/auth-test.sh

test-info:
	@bash tests/info-test.sh

test-date:
	@bash tests/date-test.sh

test-sync:
	@bash calendar-script.sh --sync

test-agenda:
	@cat ~/.today_agenda