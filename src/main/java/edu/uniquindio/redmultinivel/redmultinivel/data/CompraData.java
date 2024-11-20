package edu.uniquindio.redmultinivel.redmultinivel.data;

import edu.uniquindio.redmultinivel.redmultinivel.dtos.productodtos.ProductoCarritoDto;
import javafx.collections.ObservableList;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;

public class CompraData {

    public static int agregarAlCarrito(int afiliadoId, int productoId, int cantidad){

        int salida=0;
        String query = "{? = CALL F_AGREGAR_AL_CARRITO(?,?,?)}";

        try(Connection conn = ConexionOracle.getConn();
            CallableStatement cstmt = conn.prepareCall(query)){

            //parametros de salida
            cstmt.registerOutParameter(1, java.sql.Types.INTEGER);

            //parametros de entrada
            cstmt.setInt(2, afiliadoId);

            //parametros de entrada
            cstmt.setInt(3, productoId);

            //parametros de entrada
            cstmt.setInt(4, cantidad);

            //se ejecuta la consulta
            cstmt.execute();

            // Obtener el valor del parámetro de salida
            salida = cstmt.getInt(1);

        } catch (SQLException e) {
            throw new RuntimeException("Error al agregar producto al carrito",e);
        }
        return salida;
    }

    public static void CargarCarrito(ObservableList<ProductoCarritoDto> elementosCarrito, int affiliateId){

        for(ProductoCarritoDto productoCarritoDto : elementosCarrito){
            CompraData.agregarAlCarrito(affiliateId, productoCarritoDto.getCodigo(), productoCarritoDto.getCantidad());
        }
    }

    public static int comprarCarrito(int afiliadoId){
        int salida=0;

        String query = "{? = CALL F_COMPRAR_CARRITO(?)}";

        try(Connection conn = ConexionOracle.getConn();
            CallableStatement cstmt = conn.prepareCall(query)){

            //parametros de salida
            cstmt.registerOutParameter(1, java.sql.Types.INTEGER);

            //parametros de entrada
            cstmt.setInt(2, afiliadoId);

            //se ejecuta la consulta
            cstmt.execute();

            // Obtener el valor del parámetro de salida
            salida = cstmt.getInt(1);

        } catch (SQLException e) {
            throw new RuntimeException("Error al realizar la compra",e);
        }
        return salida;
    }





}
