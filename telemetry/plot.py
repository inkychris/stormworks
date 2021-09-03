import pandas
import plotly.express as px

def main(csv_file):
    df = pandas.read_csv(csv_file, header=None, names=['index', 'target', 'actual'])
    fig = px.scatter(data_frame=df, x='index', y=['target', 'actual'])
    fig.show()


if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument('file', type=str, help='csv file')
    args = parser.parse_args()
    main(args.file)
