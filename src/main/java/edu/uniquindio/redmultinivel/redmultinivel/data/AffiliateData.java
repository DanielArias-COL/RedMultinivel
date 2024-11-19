package edu.uniquindio.redmultinivel.redmultinivel.data;

import edu.uniquindio.redmultinivel.redmultinivel.dtos.productodtos.ProductoDto;
import javafx.scene.control.Alert;

import java.sql.*;


public class AffiliateData {

    public static int obtenerDescuentoPorId(int affiliateId)  {

        int salida=0;
        String query = "{? = CALL CALCULAR_DESCUENTO_POR_AFFILIATEID(?)}";

        try(Connection conn = ConexionOracle.getConn();
            CallableStatement cstmt = conn.prepareCall(query)){

            //parametros de salida
            cstmt.registerOutParameter(1, java.sql.Types.INTEGER);

            //parametros de entrada
            cstmt.setInt(2, affiliateId);

            //se ejecuta la consulta
            cstmt.execute();

            // Obtener el valor del parámetro de salida
            salida = cstmt.getInt(1);

        } catch (SQLException e) {

        }

        return salida;
    }

    public static void validarCredenciales(String email, String password) {

        try (Connection connection = ConexionOracle.getConn()) {
            String sql = "{CALL login_email_affiliate(?, ?)}";
            try (CallableStatement statement = connection.prepareCall(sql)) {
                statement.setString(1, email);
                statement.setString(2, password);
                statement.execute();

            }
        } catch (SQLException e) {
            throw new RuntimeException("Error al obtener El Descuento del empleado",e);
        }
    }

}
