package edu.uniquindio.redmultinivel.redmultinivel.data;

import oracle.jdbc.datasource.impl.OracleDataSource;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ConexionOracle {


    private static Connection conn;
    private String url = "jdbc:oracle:thin:@localhost:1521/orcl";
    private String usuario = "UREDMULTINIVEL";
    private String password = "UREDMULTINIVEL";




    public ConexionOracle() {
        conectar();
    }

    private static void conectar(){
        OracleDataSource ods = null;
        try {
            ods = new OracleDataSource();
            ods.setURL("jdbc:oracle:thin:@localhost:1521/orcl"); // jdbc:oracle:thin@//[hostname]:[port]/[DB service name]
            ods.setUser("UREDMULTINIVEL");
            ods.setPassword("UREDMULTINIVEL");
            conn = ods.getConnection();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public void Desconectar(){
        try{
            conn.close();
        }catch (Exception e){
            throw new RuntimeException(e);
        }
    }

    public static Connection getConn() {
        if(conn == null){
            conectar();
        }
        return conn;
    }

}
