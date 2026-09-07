const sql = require("mssql");

const config = {
    server: "sqlserver",
    port: 1433,
    user: "sa",
    password: process.env.DB_PASSWORD,
    database: "tuSanatorio",
    options: {
        encrypt: false,
        trustServerCertificate: true
    }
};

async function test() {
    try {
        const pool = await sql.connect(config);

        const result = await pool.request().query(`
            SELECT name
            FROM sys.procedures
            WHERE name IN ('getEspecialidades', 'GetObrasSociales')
            ORDER BY name
        `);

        console.log("SP encontradas:");
        console.log(result.recordset);

        await pool.close();
    } catch (error) {
        console.error("ERROR:", error.message);
    }
}

test();
