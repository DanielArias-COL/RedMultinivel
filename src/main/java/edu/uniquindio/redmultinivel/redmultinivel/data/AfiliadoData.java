package edu.uniquindio.redmultinivel.redmultinivel.data;

import edu.uniquindio.redmultinivel.redmultinivel.dtos.productodtos.LoginDto;
import edu.uniquindio.redmultinivel.redmultinivel.dtos.productodtos.ProductoDto;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class AfiliadoData {

//    public static boolean obtenerDatosLogin(String correo,String contrasenia)  {
//
//
//        LoginDto loginDto = new LoginDto();
//        //List<ProductoDto> productos = new ArrayList<>();
//
//        Connection conn = ConexionOracle.getConn();
//        PreparedStatement stmt = null;
//        try {
//            stmt = conn.prepareStatement("SELECT * FROM AFFILIATE WHERE EMAIL = " + correo);
//
//            ResultSet rslt = stmt.executeQuery();
//
//            while (rslt.next()) {
//                loginDto.setCorreo(rslt.getString("EMAIL"));
//                loginDto.setContrasenia(rslt.getString("PASSWORD"));
//                // Crea un nuevo objeto ProductoDto y asigna valores desde el ResultSet
////                ProductoDto producto = new ProductoDto();
////                producto.setCodigo(rslt.getInt("PRODUCT_ID"));
////                producto.setName(rslt.getString("NAME"));
////                producto.setValor(rslt.getDouble("SALE_PRICE"));
////                producto.setImagePath(rslt.getString("PATH_IMAGE"));
////                System.out.println(producto.toString());
////
////                // Agrega el producto a la lista
////                productos.add(producto);
//            }
//
//            conn.close();
//        } catch (SQLException e) {
//            throw new RuntimeException(e);
//        }
//
//        if(loginDto.getCorreo().equals(correo) && loginDto.getContrasenia().equals()){
//
//        }
//
//        return productos;
//
//    }
}
