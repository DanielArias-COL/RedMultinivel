package edu.uniquindio.redmultinivel.redmultinivel.dtos.productodtos;

import lombok.*;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@ToString
public class ProductoCarritoDto {
    Integer codigo;
    String nombreProducto;
    Integer cantidad;
    Double valor;


    public void incrementarCantidad(int n){
        double valorUnitario = valor/cantidad;
        cantidad += n;
        valor = valorUnitario * cantidad;
    }

    public void decrementarCantidad(int n){
        double valorUnitario = valor/cantidad;
        cantidad -= n;
        valor = valorUnitario * cantidad;
    }



}
