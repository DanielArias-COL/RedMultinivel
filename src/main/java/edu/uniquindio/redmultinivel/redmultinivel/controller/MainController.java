package edu.uniquindio.redmultinivel.redmultinivel.controller;

import java.io.IOException;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.*;

import edu.uniquindio.redmultinivel.redmultinivel.App;
import edu.uniquindio.redmultinivel.redmultinivel.data.AfiliadoData;
import edu.uniquindio.redmultinivel.redmultinivel.data.CompraData;
import edu.uniquindio.redmultinivel.redmultinivel.data.ProductoData;
import edu.uniquindio.redmultinivel.redmultinivel.dtos.productodtos.ProductoCarritoDto;
import edu.uniquindio.redmultinivel.redmultinivel.dtos.productodtos.ProductoDto;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.control.*;
import javafx.scene.control.cell.PropertyValueFactory;
import javafx.scene.layout.AnchorPane;
import javafx.scene.layout.GridPane;
import javafx.stage.Stage;

public class MainController {

    private Stage mainStage;

    private boolean carritoActivo;

    private ObservableList<ProductoCarritoDto> elementosCarrito = FXCollections.observableArrayList();

    private int affiliateId;

    private int PercentageDescount;

    private ProductoCarritoDto productoDtoSeleccionado;

    @FXML
    private TextField textFieldAffiliateId;

    @FXML
    private TextField textFieldFirstName;

    @FXML
    private TextField textFieldLastName;

    @FXML
    private TextField textFieldEmail;

    @FXML
    private TextField textFieldContrasenia;

    @FXML
    private TextField textFieldAddress;

    @FXML
    private TextField textFieldHierarchicalLevel;

    @FXML
    private TextField textFieldParentAffiliateId;

    @FXML
    private TextField textDescountValue;

    @FXML
    private TextField textOriginalValue;

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
    private GridPane gridPaneProductos;

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
    void vaciarTabla(ActionEvent event) {
        Alert alert = new Alert(Alert.AlertType.CONFIRMATION);
        alert.setTitle("Diálogo de confirmación...");
        alert.setHeaderText(null);
        alert.setContentText("Esta seguro que desea vaciar la lista");

        Optional<ButtonType> resultado = alert.showAndWait();
        if (resultado.isPresent())
        {
            if (resultado.get() == ButtonType.OK) {
                tableViewCarrito.getItems().clear();
            }
        }

    }

    @FXML
    void eliminarProductoSeleccionado(ActionEvent event) {

        if (productoDtoSeleccionado != null) {
            for(int i=0 ; i < elementosCarrito.size() ; i++) {
                if (Objects.equals(elementosCarrito.get(i).getCodigo(), productoDtoSeleccionado.getCodigo())) {
                    elementosCarrito.remove(i);
                    break;
                }
            }
            actualizarValorTotal();
            refrescarTabla();
        }else{
            mostrarDialogoInformacionSEncabezado("Seleccione un producto primero");
        }

    }

    @FXML
    void incrementarProductoEnTabla(ActionEvent event) {

        if (productoDtoSeleccionado != null) {
            for(int i=0 ; i < elementosCarrito.size() ; i++) {
                if (Objects.equals(elementosCarrito.get(i).getCodigo(), productoDtoSeleccionado.getCodigo())) {
                    elementosCarrito.get(i).incrementarCantidad(1);
                    break;
                }
            }
            actualizarValorTotal();
            refrescarTabla();
        }else{
            mostrarDialogoInformacionSEncabezado("Seleccione un producto primero");
        }
    }

    @FXML
    void decrementarProductoEnTabla(ActionEvent event) {

        if (productoDtoSeleccionado != null) {
            for(int i=0 ; i < elementosCarrito.size() ; i++) {
                if (Objects.equals(elementosCarrito.get(i).getCodigo(), productoDtoSeleccionado.getCodigo())) {
                    if (elementosCarrito.get(i).getCantidad()>1){
                        elementosCarrito.get(i).decrementarCantidad(1);
                        break;
                    }

                }
            }
            actualizarValorTotal();
            refrescarTabla();
        }else{
            mostrarDialogoInformacionSEncabezado("Seleccione un producto primero");
        }
    }

    /**
     * Este metodo se divide en dos:
     * 1. crea el carrito en la base de datos y le agrega los productos
     * 2. Genera la compra del carrito
     * @param event
     */
    @FXML
    void comprarCarrito(ActionEvent event) {
        actualizarCarrito();

        int respuesta = CompraData.comprarCarrito(affiliateId);
        if( respuesta != 0){
            mostrarDialogoInformacionSEncabezado("Compra exitosa");
            elementosCarrito.clear();
            actualizarValorTotal();

        }else{
            mostrarDialogoInformacionSEncabezado("Hubo un error al generar la compra");
        }


    }

    //Cuadro de diálogo de información sin encabezado
    public void mostrarDialogoInformacionSEncabezado(String mensaje) {
        Alert alert = new Alert(Alert.AlertType.INFORMATION);
        alert.setTitle("Diálogo de información...");
        alert.setHeaderText(null);
        alert.setContentText(mensaje);
        alert.showAndWait();
    }

    @FXML
    public void initialize(Stage mainStage, int affiliateId) {
        this.mainStage = mainStage;
        this.affiliateId = affiliateId;
        this.PercentageDescount = AfiliadoData.obtenerDescuentoPorId(affiliateId);
        this.carritoActivo = AfiliadoData.verificarSihayCarritoActivo(affiliateId);
        iniciarTablaCarrito();
        cargarproductos();
        crearEventoCerrarVentana();
    }

    private void crearEventoCerrarVentana() {
        mainStage.setOnCloseRequest(event -> {
            event.consume();

            cerrarVentana(mainStage);
        });
    }

    /**
     * Este método nos va a permitir guardar los productos del carrito cual el cliente sale de la app
     * @param mainStage
     */
    private void cerrarVentana(Stage mainStage) {

        actualizarCarrito();

        mainStage.close();
    }

    /**
     * Este método nos permite agregar el producto al carrito, si el producto ya se encuentra en el carrito simplemente se actualiza su
     * cantidad y valor
     *
     * @autrhor Daniel Arias
     * @param codigo
     * @param nombreProducto
     * @param cantidad
     * @param valor
     */
    public void agregarAlCarrito(Integer codigo, String nombreProducto, Integer cantidad, Double valor) {

        if(buscarProductoEnCarrito(codigo)){
            for (int i = 0; i < elementosCarrito.size(); i++) {
                if(Objects.equals(elementosCarrito.get(i).getCodigo(), codigo)){
                    elementosCarrito.get(i).setCantidad(cantidad);
                    elementosCarrito.get(i).setValor(valor);
                    actualizarValorTotal();
                    refrescarTabla();
                    break;
                }
            }
        }else{
            ProductoCarritoDto item = new ProductoCarritoDto(codigo,nombreProducto,cantidad,valor);
            elementosCarrito.add(item);
            actualizarValorTotal();
        }

    }

    private void actualizarValorTotal() {

        int valor = 0;

        for( ProductoCarritoDto item : elementosCarrito){
             valor += item.getValor();
        }

        double valorConDescuento = valor-((valor) * (PercentageDescount/100.0));
        textOriginalValue.setText(Double.toString(valor));
        textDescountValue.setText(Double.toString(valorConDescuento));

    }

    private boolean buscarProductoEnCarrito(Integer codigo) {

        for( ProductoCarritoDto item : elementosCarrito){
            if(Objects.equals(item.getCodigo(), codigo)){
                return true;
            }
        }

        return false;

    }


    /**
     * Este método nos permite inicializar todas las tablas del carrito,
     * además valida si el carrito al cerrar una sesión quedo con productos y los carga nuevamente
     * selección
     *
     * @author Daniel Arias
     */
    private void iniciarTablaCarrito() {
        //los nombres que se le dan como codigo,fechaInicio tienen que estar igual a como aparecen en el paquete util
        //se vincula elementos del objetos con cada una de las columnas de la tabla
        tableColumnCodigo.setCellValueFactory(new PropertyValueFactory<ProductoCarritoDto, Integer>("codigo"));
        tableColumnNombreProducto.setCellValueFactory(new PropertyValueFactory<ProductoCarritoDto, String>("nombreProducto"));
        tableColumnCantidad.setCellValueFactory(new PropertyValueFactory<ProductoCarritoDto, Integer>("cantidad"));
        tableColumnValor.setCellValueFactory(new PropertyValueFactory<ProductoCarritoDto, Double>("valor"));

        tableViewCarrito.getSelectionModel().selectedItemProperty().addListener((obs,oldSelection,newSelection) ->{
            productoDtoSeleccionado = newSelection;
        });

        if(carritoActivo){
            cargarElementosCarrito();
            actualizarValorTotal();
        }

        tableViewCarrito.setItems(elementosCarrito);
    }

    /**
     * se trae todo el carrito de la base de datos
     */
    private void cargarElementosCarrito() {
        ArrayList<ProductoCarritoDto> productosEnCarrito = AfiliadoData.obtenerDatosCarrito(affiliateId);

        if (!productosEnCarrito.isEmpty()) {
            elementosCarrito.addAll(productosEnCarrito);
        }

    }

    public void actualizarCarrito(){
        AfiliadoData.actualizarCarrito(elementosCarrito, affiliateId);
    }

    private void refrescarTabla() {
        tableViewCarrito.refresh();
    }

    /**
     *Este método realiza la consulta a la base de datos y carga los productos
     *disponibles en el gridPane
     *
     * @author Daniel Arias
     */
    public void cargarproductos(){

        List<ProductoDto> productos = ProductoData.obtenerProductosDTO();

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

    /**
     *Este método nos permite la creación de una instancia del anchor pane que
     * contiene cada producto individual
     *
     * @author Daniel Arias
     * @param productoDto
     * @return
     */
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


    @FXML
    private void agregarAfiliado() {
        // Capturar los valores ingresados
        String affiliateId = textFieldAffiliateId.getText();
        String firstName = textFieldFirstName.getText();
        String lastName = textFieldLastName.getText();
        String email = textFieldEmail.getText();
        String address = textFieldAddress.getText();
        String contrasenia = textFieldContrasenia.getText();

        System.out.println("aca va el llamado para crear el afiliado");
    }

/////////////////////////////
@FXML
private TextField txtAffiliateId;

    // Método para eliminar un afiliado al presionar el botón
    @FXML
    public void eliminarAfiliado() {
        String affiliateId = txtAffiliateId.getText();

        if (affiliateId == null || affiliateId.trim().isEmpty()) {
            mostrarAlerta(Alert.AlertType.ERROR, "Error", "Debe ingresar un ID válido.");
            return;
        }

        try (Connection connection = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "felipe", "12345");
             CallableStatement statement = connection.prepareCall("{CALL eliminar_affiliate(?)}")) {

            // Pasar el ID del afiliado como parámetro al procedimiento
            statement.setInt(1, Integer.parseInt(affiliateId));

            // Ejecutar el procedimiento almacenado
            statement.execute();

            // Mostrar mensaje de éxito
            mostrarAlerta(Alert.AlertType.INFORMATION, "Éxito", "El afiliado fue eliminado correctamente.");

        } catch (SQLException e) {
            // Manejar errores de SQL
            mostrarAlerta(Alert.AlertType.ERROR, "Error", "Ocurrió un error al intentar eliminar el afiliado: " + e.getMessage());
        } catch (NumberFormatException e) {
            // Manejar errores de formato
            mostrarAlerta(Alert.AlertType.ERROR, "Error", "El ID del afiliado debe ser un número.");
        }
    }

    // Método para mostrar alertas en pantalla
    private void mostrarAlerta(Alert.AlertType tipo, String titulo, String mensaje) {
        Alert alerta = new Alert(tipo);
        alerta.setTitle(titulo);
        alerta.setContentText(mensaje);
        alerta.showAndWait();
    }

    private void eventocerrarVenta(){


        if (elementosCarrito.isEmpty()){
            System.out.println("se guardan automaticamente ");
        }
    }
}
