package edu.uniquindio.redmultinivel.redmultinivel.controller;

import java.io.IOException;
import java.net.URL;
import java.util.List;
import java.util.ResourceBundle;

import edu.uniquindio.redmultinivel.redmultinivel.App;
import edu.uniquindio.redmultinivel.redmultinivel.data.ProductoData;
import edu.uniquindio.redmultinivel.redmultinivel.dtos.productodtos.ProductoCarritoDto;
import edu.uniquindio.redmultinivel.redmultinivel.dtos.productodtos.ProductoDto;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.control.Button;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.control.cell.PropertyValueFactory;
import javafx.scene.layout.AnchorPane;
import javafx.scene.layout.GridPane;

public class MainController {

    private ObservableList<ProductoCarritoDto> elementosCarrito = FXCollections.observableArrayList();


    @FXML
    private TableView<ProductoCarritoDto> tableViewCarrito;

    @FXML
    private TableColumn<ProductoCarritoDto, Integer> tableColumnCodigo;

    @FXML
    private TableColumn<ProductoCarritoDto, String> tableColumnNombreProducto;


    @FXML
    private TableColumn<ProductoCarritoDto, Integer> tableColumnCantidad;

    @FXML
    private TableColumn<ProductoCarritoDto, Double> tableColumnValor;




    @FXML
    private ResourceBundle resources;

    @FXML
    private GridPane gridPaneProductos;

    @FXML
    private URL location;

    @FXML
    private AnchorPane anchorPaneAgregarTienda;

    @FXML
    private Button buttonTienda;

    @FXML
    private Button buttonComision;

    @FXML
    private AnchorPane anchorPaneComision;

    @FXML
    private AnchorPane anchorPaneAgregarEquipo;

    @FXML
    private AnchorPane anchorPaneCarrito;

    @FXML
    void ActivarPanelTienda(ActionEvent event) {
        anchorPaneComision.setVisible(false);
        anchorPaneAgregarEquipo.setVisible(false);
        anchorPaneAgregarTienda.setVisible(true);
        anchorPaneCarrito.setVisible(true);
    }

    @FXML
    void ActivarPanelComision(ActionEvent event) {
        anchorPaneAgregarEquipo.setVisible(false);
        anchorPaneAgregarTienda.setVisible(false);
        anchorPaneCarrito.setVisible(false);
        anchorPaneComision.setVisible(true);
    }


    @FXML
    void ActivarPanelAgregarEquipo(ActionEvent event) {
        anchorPaneAgregarTienda.setVisible(false);
        anchorPaneCarrito.setVisible(false);
        anchorPaneComision.setVisible(false);
        anchorPaneAgregarEquipo.setVisible(true);
    }



    @FXML
    void initialize() {
        assert anchorPaneAgregarTienda != null : "fx:id=\"anchorPaneAgregarTienda\" was not injected: check your FXML file 'main-view.fxml'.";
        assert buttonTienda != null : "fx:id=\"buttonTienda\" was not injected: check your FXML file 'main-view.fxml'.";
        assert buttonComision != null : "fx:id=\"buttonComision\" was not injected: check your FXML file 'main-view.fxml'.";
        assert anchorPaneComision != null : "fx:id=\"anchorPaneComision\" was not injected: check your FXML file 'main-view.fxml'.";
        assert anchorPaneAgregarEquipo != null : "fx:id=\"anchorPaneAgregarEquipo\" was not injected: check your FXML file 'main-view.fxml'.";

    }

    public void agregarAlCarrito(Integer codigo, String nombreProducto, Integer cantidad, Double valor) {

        ProductoCarritoDto item = new ProductoCarritoDto(codigo,nombreProducto,cantidad,valor);
        elementosCarrito.add(item);

    }
    public void init(App app) {

        //los nombres que se le dan como codigo,fechaInicio tienen que estar igual a como aparecen en el paquete util
        //se vincula elementos del objetos con cada una de las columnas de la tabla
        tableColumnCodigo.setCellValueFactory(new PropertyValueFactory<ProductoCarritoDto, Integer>("codigo"));
        tableColumnNombreProducto.setCellValueFactory(new PropertyValueFactory<ProductoCarritoDto, String>("nombreProducto"));
        tableColumnCantidad.setCellValueFactory(new PropertyValueFactory<ProductoCarritoDto, Integer>("cantidad"));
        tableColumnValor.setCellValueFactory(new PropertyValueFactory<ProductoCarritoDto, Double>("valor"));

        tableViewCarrito.setItems(elementosCarrito);


        cargarproductos();
    }

    public void cargarproductos(){


        List<ProductoDto> productos = ProductoData.obtenerProductosDTO();


        //calcular la cantidad de filas necesarias
        int cantidadProductos = productos.size();
        int filas = 3;
        int columnas =3;

        if (cantidadProductos > 9) {
            int cantidadDeFilasAdicionales = (int) Math.ceil((cantidadProductos-9)/3);
            this.gridPaneProductos.addRow(cantidadDeFilasAdicionales);
            filas += cantidadDeFilasAdicionales;
        }

        int i=0;
        int j=0;

        for (ProductoDto productoDto : productos) {
            AnchorPane nodoProducto = crearNodoProducto(productoDto);
            if(j==2){
                gridPaneProductos.add(nodoProducto,j,i);
                j=0;
                i+=1;
            }else{
                gridPaneProductos.add(nodoProducto,j,i);
                j++;
            }

        }


    }

    private AnchorPane crearNodoProducto(ProductoDto productoDto) {
        AnchorPane ContenedorProducto = null;

        try {
            //Creamos la clase FXMLLoader que nos permite cargar archivos fxml
            FXMLLoader loader = new FXMLLoader();
            loader.setLocation(App.class.getResource("produc-view.fxml"));

            //Ahoraa se lee el archivo previamente cargado y se crea el arbol de nodos y se le asigna a el contenedor
            ContenedorProducto = (AnchorPane)loader.load();

            //Damos acceso al controlador a la vista
            ProductMainController controller= loader.getController();

            controller.init(productoDto, this);

        } catch (IOException e) {
            throw new RuntimeException(e);
        }


        return ContenedorProducto;
    }
}
