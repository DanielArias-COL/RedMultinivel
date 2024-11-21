package edu.uniquindio.redmultinivel.redmultinivel.data;

import oracle.jdbc.datasource.impl.OracleDataSource;
import java.sql.Connection;
import java.sql.SQLException;

public class ConexionOracle {


    private static Connection conn;
    private static String url = "jdbc:oracle:thin:@localhost:1521/xe";
    private static String usuario = "felipe";
    private static String password = "12345";




    public ConexionOracle() {
        conectar();
    }

    private static void conectar(){
        OracleDataSource ods = null;
        try {
            ods = new OracleDataSource();
            ods.setURL(url); // jdbc:oracle:thin@//[hostname]:[port]/[DB service name]
            ods.setUser(usuario);
            ods.setPassword(password);
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
        try {
            if(conn == null || conn.isClosed()){
                conectar();
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return conn;
    }

}
