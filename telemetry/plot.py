import csv
import plotly.graph_objects as go


def parse_csv(file):
    x = []
    y = []
    with open(file, 'r', newline='') as csvfile:
        data = csv.reader(csvfile)
        for row in data:
            x.append(row[0])
            y.append(row[1])
    return x, y


if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument('file', type=str, help='csv file')

    args = parser.parse_args()

    x, y = parse_csv(args.file)
    fig = go.Figure(data=go.Scatter(x=x, y=y))
    fig.show()
