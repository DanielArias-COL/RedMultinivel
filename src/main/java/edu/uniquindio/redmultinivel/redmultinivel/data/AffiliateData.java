package edu.uniquindio.redmultinivel.redmultinivel.data;

import edu.uniquindio.redmultinivel.redmultinivel.dtos.productodtos.ProductoDto;

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
            throw new RuntimeException("Error al obtener El Descuento del empleado",e);
        }

        return salida;
    }

}
