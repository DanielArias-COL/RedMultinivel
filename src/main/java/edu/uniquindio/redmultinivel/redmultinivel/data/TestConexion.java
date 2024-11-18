package edu.uniquindio.redmultinivel.redmultinivel.data;

import oracle.jdbc.datasource.impl.OracleDataSource;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class TestConexion {

    public static void main(String[] args) throws SQLException {

        OracleDataSource ods = new OracleDataSource();
        ods.setURL("jdbc:oracle:thin:@localhost:1521/xe"); // jdbc:oracle:thin@//[hostname]:[port]/[DB service name]
        ods.setUser("FELIPE");
        ods.setPassword("12345");
        Connection conn = ods.getConnection();

        // Elimina el punto y coma
        PreparedStatement stmt = conn.prepareStatement("SELECT * FROM PRODUCT");
        ResultSet rslt = stmt.executeQuery();
        while (rslt.next()) {
            System.out.println(rslt.getString(1));
        }

        // Cierre de recursos (opcional pero recomendado)
        rslt.close();
        stmt.close();
        conn.close();

    }
}
