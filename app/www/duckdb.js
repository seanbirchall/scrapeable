import * as duckdb from "https://cdn.jsdelivr.net/npm/@duckdb/duckdb-wasm@1.28.1-dev106.0/+esm";

let db = null;
let conn = null;
let currentUrl = null;

async function initializeDatabase() {
  if (db === null) {
    Shiny.setInputValue("duckdb_initialized", false);
    const JSDELIVR_BUNDLES = duckdb.getJsDelivrBundles();
    const bundle = await duckdb.selectBundle(JSDELIVR_BUNDLES);
    const worker_url = URL.createObjectURL(
      new Blob([`importScripts("${bundle.mainWorker}");`], { type: 'text/javascript' })
    );
    const worker = new Worker(worker_url);
    const logger = new duckdb.ConsoleLogger();
    db = new duckdb.AsyncDuckDB(logger, worker);
    await db.instantiate(bundle.mainModule, bundle.pthreadWorker);
    URL.revokeObjectURL(worker_url);
    await db.open({
      path: ':memory:',
      query: { castTimestampToDate: true }
    });
    Shiny.setInputValue("duckdb_initialized", true);
    //console.log("DuckDB instance initialized");
  }
}

async function executeSql(sql, id) {
  try {
    if (!conn) {
      await initializeDatabase();
    }
    conn = await db.connect();
    const result = await conn.query(sql);
    const serializedResult = JSON.stringify(result.toArray(), replacer);
    Shiny.setInputValue("duckdb_sql_result", {
      data: serializedResult,
      id: id,
      query: sql,
      error: false,
      message: "success"
    });
  } catch (error) {
    if (error.message.includes("database has been invalidated")) {
      await resetDuckdb();
    }
    const errorResult = JSON.stringify({ error: error.message });
    Shiny.setInputValue("duckdb_sql_result", {
      data: null,
      id: id,
      query: sql,
      error: true,
      message: errorResult
    });
  }
}

Shiny.addCustomMessageHandler("duckdb_sql", function(message) {
  executeSql(message.sql, message.id);
});

async function connectToDatabase(url) {
  if (currentUrl === url) {
    //console.log("Already connected to this database");
    return;
  }

  try {
    await initializeDatabase();

    if (conn) {
      await conn.close();
    }
    conn = await db.connect();

    // Detach all databases except 'memory' and 'system'
    const attachedDatabases = await conn.query(`
      SELECT database_name FROM duckdb_databases()
      WHERE database_name NOT IN ('memory', 'system', 'temp')
    `);
    for (const row of attachedDatabases.toArray()) {
      await conn.query(`DETACH DATABASE IF EXISTS "${row.database_name}"`);
    }

    // Attach the new database
    await conn.query(`ATTACH '${url}' AS sc (READ_ONLY)`);
    currentUrl = url;
    Shiny.setInputValue("duckdb_attached", true);
    //console.log(`Connected to database: ${url}`);
  } catch (error) {
    Shiny.setInputValue("duckdb_attached", false);
    //console.error("Error connecting to database:", error);
    throw error;
  }
}

function replacer(key, value) {
  return typeof value === 'bigint' ? value.toString() : value;
}

async function resetDuckdb() {
  // Close the existing connection
  if (conn) {
    await conn.close();
    conn = null;
  }

  // Reset the database instance
  if (db) {
    db = null;
    currentUrl = null;
  }

  // Reinitialize DuckDB
  await initializeDuckdb();
  console.log("DuckDB instance has been reset.");
}

async function runQuery(query, url, id) {
  try {
    await connectToDatabase(url);
    const result = await conn.query(query);
    const serializedResult = JSON.stringify(result.toArray(), replacer);
    Shiny.setInputValue("duckdb_r_result", {
      data: serializedResult,
      id: id,
      query: query,
      error: false,
      message: "success"
    });
    //console.log("Query ran successfully");
  } catch (error) {
    if (error.message.includes("database has been invalidated")) {
      await resetDuckdb();
    }
    const errorResult = JSON.stringify({ error: error.message });
    Shiny.setInputValue("duckdb_r_result", {
      data: null,
      id: id,
      query: query,
      error: true,
      message: errorResult
    });
    //console.error("Error running query:", error);
  }
}

Shiny.addCustomMessageHandler("duckdb_r", function(message) {
  runQuery(message.query, message.url, message.id);
});
