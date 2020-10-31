import csv
import datetime
import fastapi
import pathlib
import threading


class Logger:
    def __init__(self, *, dataset_timeout, output_dir=None):
        self._data = []
        self._output_dir = pathlib.Path(output_dir or 'data') / datetime.datetime.now().isoformat().replace(':', '-').replace('.', '-')
        self._dataset_timeout = datetime.timedelta(seconds=dataset_timeout)
        self._last_logged = None
        self._auto_dump = True
        self._dump_thread = None
        self._dump_count = 0

    def dump_reset_on_timeout(self):
        now = datetime.datetime.now()
        if self._last_logged and self._last_logged + self._dataset_timeout < now:
            self.dump()
            self.reset()

    def reset(self):
        self._data = []

    def log(self, packet):
        for entry in packet.split('|'):
            self._data.append(entry.split(':'))
        self._last_logged = datetime.datetime.now()

    def dump(self):
        if not self._data:
            return
        self._output_dir.mkdir(exist_ok=True, parents=True)
        with open(self._output_dir / f'{self._dump_count}.csv', 'w', newline='') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(['index', 'value'])
            for entry in self._data:
                writer.writerow(entry)
        self._dump_count += 1

    def __enter__(self):
        return self

    def _dump_thread_target(self):
        while self._auto_dump:
            self.dump_reset_on_timeout()

    def start_auto_dump(self):
        self._auto_dump = True
        self._dump_thread = threading.Thread(target=self._dump_thread_target)
        self._dump_thread.start()

    def stop_auto_dump(self):
        if self._dump_thread:
            self._auto_dump = False
            self._dump_thread.join()


logger = Logger(dataset_timeout=5)
logger.start_auto_dump()
app = fastapi.FastAPI()

@app.get('/log')
def log(packet: str):
    logger.log(packet)
    return "OK!"

@app.get('/dump')
def dump():
    logger.dump()
    return "OK!"

@app.get('/reset')
def dump():
    logger.reset()
    return "OK!"

@app.on_event('shutdown')
def cleanup_logger():
    logger.stop_auto_dump()
    logger.dump()
