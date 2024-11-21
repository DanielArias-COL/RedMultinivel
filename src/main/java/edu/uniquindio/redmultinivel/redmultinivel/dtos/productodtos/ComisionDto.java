package edu.uniquindio.redmultinivel.redmultinivel.dtos.productodtos;

import lombok.*;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@ToString
public class ComisionDto {
    private Integer comisionId;  //YA
    private Long cedulaVendedor; //YA
    private String nombreVendedor; //YA
    private String apellidoVendedor;//YA
    private Integer ventaAsociada; //YA
    private Double valor; //YA
}
