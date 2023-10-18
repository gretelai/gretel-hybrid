#!/usr/bin/env python

import argparse
import shutil

import smart_open


def main(bucket_path: str, file_name: str):
    with open(file_name, "rb") as source:
        with smart_open.open(f"{bucket_path}/{file_name}", "wb") as target:
            shutil.copyfileobj(source, target)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--bucket-path", required=True)
    parser.add_argument("--file-name", required=True)
    args = parser.parse_args()
    main(args.bucket_path, args.file_name)
