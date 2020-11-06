import csv
import datetime
import fastapi
import pathlib
import threading


class Logger:
    def __init__(self, *, dataset_timeout):
        self._data = []
        day_dir = pathlib.Path('data') / datetime.datetime.now().strftime('%Y-%m-%d')
        instance_index = max((int(file.stem) for file in day_dir.glob('*')), default=0)
        if any((day_dir / str(instance_index)).glob('*.csv')):
            instance_index += 1
        self._output_dir = day_dir / str(instance_index)
        self._dataset_timeout = datetime.timedelta(seconds=dataset_timeout)
        self._last_logged = None
        self._dumped_latest = False
        self._auto_dump = True
        self._dump_thread = None
        self._instance_index = 0

    def dump_reset_on_timeout(self):
        now = datetime.datetime.now()
        if not self._dumped_latest and self._last_logged  and self._last_logged + self._dataset_timeout < now:
            self.dump()
            self.reset()
            self._dumped_latest = True

    def reset(self):
        self._instance_index += 1
        self._data = []

    def log(self, packet):
        self._dumped_latest = False
        for entry in packet.split('|'):
            self._data.append(entry.split(':'))
        self._last_logged = datetime.datetime.now()

    def dump(self):
        if not self._data:
            return
        self._output_dir.mkdir(exist_ok=True, parents=True)
        with open(self._output_dir / f'{self._instance_index}.csv', 'w', newline='') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(['index', 'value'])
            for entry in self._data:
                writer.writerow(entry)

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
