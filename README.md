# Running LSST on ClickHouse

A [recent blog post](https://www.monetdb.org/blog/lsst-in-monetdb
) presented experiments with (synthetic) data as expected from the [Large Synoptic Survey Telescope (LSST)](https://www.lsst.org/about). Here, we describe a repetition of those experiments with [ClickHouse](https://clickhouse.yandex), an analytical DBMS developed by Yandex and released as Open Source. 

 Fabrice Jammes and his team from LSST-France kindly provided us with 2 TB of artificial LSST CSV files. The files (~300GB compressed) are [available for download](https://sisyphus.project.cwi.nl/.lsst/). The dataset consists of four main tables, each partitioned to cover a specific area of the sky. The data is structured into the following tables:
 - `Source`: 1.465.686.816 rows, 87 columns
 - `ForcedSource`: 7.194.676.239 rows, 13 columns
 - `Object`: 79.226.537 rows, 236 columns
 - `ObjectFullOverlap`: 32.485.682 rows, 236 columns

To load this data, we have created a schema definition for ClickHouse using the `TinyLog` table engine for each of the partitions, and the [`Merge` table engine](https://clickhouse.yandex/docs/en/table_engines/merge.html) to combine them into a single virtual table for querying. For details, see the schema definition [in this repository](LSST-clickhouse-schema.sql). We used a parallel load:

````
ls *.csv.xz | xargs -n 1 -P 8 -I % sh -c 'T=`basename % .csv.xz`; xzcat % | sed -e "s/;/,/g" -e 's/NULL//g' | clickhouse client --query "INSERT INTO $T FORMAT CSVWithNames"'
````

After loading, we ran the same 13 benchmark queries as before, after some adaptation to ClickHouse. The main difference is in Q13, which uses a selfjoin with range predicates to find overlapping sources. The queries as used are also [in this repository](LSST-clickhouse-queries.sql).

To be continued...
