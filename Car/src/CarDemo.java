import javax.swing.*; 
import javax.swing.border.*; 
import javax.swing.table.*;
import java.awt.*; 
import java.awt.event.*; 
 
import java.util.Locale;
import java.util.ResourceBundle;
import java.util.MissingResourceException;

import CLIPSJNI.*;

/* TBD module qualifier with find-all-facts */

/*

Notes:

This example creates just a single environment. If you create multiple environments,
call the destroy method when you no longer need the environment. This will free the
C data structures associated with the environment.

   clips = new Environment();
      .
      . 
      .
   clips.destroy();

Calling the clear, reset, load, loadFacts, run, eval, build, assertString,
and makeInstance methods can trigger CLIPS garbage collection. If you need
to retain access to a PrimitiveValue returned by a prior eval, assertString,
or makeInstance call, retain it and then release it after the call is made.

   PrimitiveValue pv1 = clips.eval("(myFunction foo)");
   pv1.retain();
   PrimitiveValue pv2 = clips.eval("(myFunction bar)");
      .
      .
      .
   pv1.release();

*/

class CarDemo implements ActionListener
  {  
   JFrame jfrm;
   
   DefaultTableModel carList;
  
   JComboBox preferredType; 
   JComboBox preferredRoad; 
   JComboBox preferredDrive; 

   JComboBox mainMark; 
   JComboBox tuning; 
   JComboBox fuel; 
   
   JLabel jlab; 

   String preferredTypeNames[] = { "Don't Care", "Hatcback", "USF" }; 
   String preferredRoadNames[] = { "Don't Care", "OFFROAD", "HIGHWAY", "TRACK" }; 
   String preferredDriveNames[] = { "Don't Care", "4wd", "rwd", "fwd" }; 
   
   String mainMarkNames[] = { "Don't Know", "WALKSWAGEN", "BUGATTI", "AUDI", "MANSORY", "MERSEDES", "POSEIDON", "BMW",  "Other" };
   String tuningNames[] = { "Don't Know", "None", "AMG", "BRABUS", "GARAGE", "Other" };
   String fuelNames[] = { "Don't Know", "GAS", "BENZINE", "DIZEL" };
 
   String preferredTypeChoices[] = new String[3]; 
   String preferredRoadChoices[] = new String[4]; 
   String preferredDriveChoices[] = new String[4]; 
   
   String mainMarkChoices[] = new String[9];
   String tuningChoices[] = new String[6];
   String fuelChoices[] = new String[4];

   ResourceBundle carResources;

   Environment clips;
   
   boolean isExecuting = false;
   Thread executionThread;

class WeightCellRenderer extends JProgressBar implements TableCellRenderer 
     {
      /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public WeightCellRenderer() 
        {
         super(JProgressBar.HORIZONTAL,0,100);
         setStringPainted(false);
        }
  
      public Component getTableCellRendererComponent(
        JTable table, 
        Object value,
        boolean isSelected, 
        boolean hasFocus, 
        int row, 
        int column) 
        { 
         setValue(((Number) value).intValue());
         return WeightCellRenderer.this; 
        }
     }
      
   /************/
   /* CARDemo */
   /************/
   CarDemo()
     {  
      try
        {
         carResources = ResourceBundle.getBundle("resources.CarResources",Locale.getDefault());
        }
      catch (MissingResourceException mre)
        {
         mre.printStackTrace();
         return;
        }

      preferredTypeChoices[0] = carResources.getString("Don'tCare"); 
      preferredTypeChoices[1] = carResources.getString("Hatcback"); 
      preferredTypeChoices[2] = carResources.getString("USF"); 
      
      preferredRoadChoices[0] = carResources.getString("Don'tCare"); 
      preferredRoadChoices[1] = carResources.getString("OFFROAD"); 
      preferredRoadChoices[2] = carResources.getString("HIGHWAY"); 
      preferredRoadChoices[3] = carResources.getString("TRACK"); 

      preferredDriveChoices[0] = carResources.getString("Don'tCare"); 
      preferredDriveChoices[1] = carResources.getString("4wd"); 
      preferredDriveChoices[2] = carResources.getString("rwd"); 
      preferredDriveChoices[3] = carResources.getString("fwd"); 
      
      mainMarkChoices[0] = carResources.getString("Don'tKnow"); 
      mainMarkChoices[1] = carResources.getString("WALKSWAGEN"); 
      mainMarkChoices[2] = carResources.getString("BUGATTI"); 
      mainMarkChoices[3] = carResources.getString("AUDI"); 
      mainMarkChoices[4] = carResources.getString("MANSORY"); 
      mainMarkChoices[5] = carResources.getString("MERSEDES");
      mainMarkChoices[6] = carResources.getString("POSEIDON");
      mainMarkChoices[7] = carResources.getString("BMW");
      mainMarkChoices[8] = carResources.getString("Other"); 
      
      tuningChoices[0] = carResources.getString("Don'tKnow"); 
      tuningChoices[1] = carResources.getString("None"); 
      tuningChoices[2] = carResources.getString("BRABUS"); 
      tuningChoices[3] = carResources.getString("AMG"); 
      tuningChoices[4] = carResources.getString("GARAGE"); 
      tuningChoices[5] = carResources.getString("Other"); 

      fuelChoices[0] = carResources.getString("Don'tKnow"); 
      fuelChoices[1] = carResources.getString("GAS"); 
      fuelChoices[2] = carResources.getString("BENZINE"); 
      fuelChoices[3] = carResources.getString("DIZEL"); 

      /*===================================*/
      /* Create a new JFrame container and */
      /* assign a layout manager to it.    */
      /*===================================*/
     
      jfrm = new JFrame(carResources.getString("CarDemo"));          
      jfrm.getContentPane().setLayout(new BoxLayout(jfrm.getContentPane(),BoxLayout.Y_AXIS));
    
      /*=================================*/
      /* Give the frame an initial size. */
      /*=================================*/
     
      jfrm.setSize(480,390);  
  
      /*=============================================================*/
      /* Terminate the program when the user closes the application. */
      /*=============================================================*/
     
      jfrm.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);  
 
      /*===============================*/
      /* Create the preferences panel. */
      /*===============================*/
      
      JPanel preferencesPanel = new JPanel(); 
      GridLayout theLayout = new GridLayout(3,2);
      preferencesPanel.setLayout(theLayout);   
      preferencesPanel.setBorder(BorderFactory.createTitledBorder(BorderFactory.createEtchedBorder(),
                                                                 carResources.getString("PreferencesTitle"),
                                                                 TitledBorder.CENTER,
                                                                 TitledBorder.ABOVE_TOP));
 
      preferencesPanel.add(new JLabel(carResources.getString("TypeLabel")));
      preferredType = new JComboBox(preferredTypeChoices); 
      preferencesPanel.add(preferredType);
      preferredType.addActionListener(this);
     
      preferencesPanel.add(new JLabel(carResources.getString("RoadLabel")));
      preferredRoad = new JComboBox(preferredRoadChoices); 
      preferencesPanel.add(preferredRoad);
      preferredRoad.addActionListener(this);

      preferencesPanel.add(new JLabel(carResources.getString("DriveLabel")));
      preferredDrive = new JComboBox(preferredDriveChoices); 
      preferencesPanel.add(preferredDrive);
      preferredDrive.addActionListener(this);

      /*========================*/
      /* Create the mark panel. */
      /*========================*/
     
      JPanel markPanel = new JPanel(); 
      theLayout = new GridLayout(3,2);
      markPanel.setLayout(theLayout);   
      markPanel.setBorder(BorderFactory.createTitledBorder(BorderFactory.createEtchedBorder(),
                                                                 carResources.getString("CarTitle"),
                                                                 TitledBorder.CENTER,
                                                                 TitledBorder.ABOVE_TOP));
 
      markPanel.add(new JLabel(carResources.getString("MainMarkLabel")));
      mainMark = new JComboBox(mainMarkChoices); 
      markPanel.add(mainMark);
      mainMark.addActionListener(this);
    
      markPanel.add(new JLabel(carResources.getString("TuningLabel")));
      tuning = new JComboBox(tuningChoices); 
      markPanel.add(tuning);
      tuning.addActionListener(this);

      markPanel.add(new JLabel(carResources.getString("FuelLabel")));
      fuel = new JComboBox(fuelChoices); 
      markPanel.add(fuel);
      fuel.addActionListener(this);
      
      /*==============================================*/
      /* Create a panel including the preferences and */
      /* meal panels and add it to the content pane.  */
      /*==============================================*/

      JPanel choicesPanel = new JPanel(); 
      choicesPanel.setLayout(new FlowLayout());
      choicesPanel.add(preferencesPanel);
      choicesPanel.add(markPanel);
      
      jfrm.getContentPane().add(choicesPanel); 
 
      /*==================================*/
      /* Create the recommendation panel. */
      /*==================================*/

      carList = new DefaultTableModel();

      carList.setDataVector(new Object[][] { },
                             new Object[] { carResources.getString("CarTitle"), 
                                            carResources.getString("RecommendationTitle")});
         
      JTable table = 
         new JTable(carList)
           {
            public boolean isCellEditable(int rowIndex,int vColIndex) 
              { return false; }
           };

      table.setCellSelectionEnabled(false); 

      WeightCellRenderer renderer = this.new WeightCellRenderer(); 
      renderer.setBackground(table.getBackground());

      table.getColumnModel().getColumn(1).setCellRenderer(renderer);

      JScrollPane pane = new JScrollPane(table);
    
      table.setPreferredScrollableViewportSize(new Dimension(450,210)); 
        
      /*===================================================*/
      /* Add the recommendation panel to the content pane. */
      /*===================================================*/

      jfrm.getContentPane().add(pane); 

      /*===================================================*/
      /* Initially select the first item in each ComboBox. */
      /*===================================================*/
       
      preferredType.setSelectedIndex(0); 
      preferredRoad.setSelectedIndex(0); 
      preferredDrive.setSelectedIndex(0); 
      mainMark.setSelectedIndex(0);
      tuning.setSelectedIndex(0);
      fuel.setSelectedIndex(0);

      /*========================*/
      /* Load the wine program. */
      /*========================*/
      
      clips = new Environment();
      
      clips.load("cardemo.clp");
      
      try
        { runCar(); }
      catch (Exception e)
        { e.printStackTrace(); }
       
      /*====================*/
      /* Display the frame. */
      /*====================*/

      jfrm.pack();
      jfrm.setVisible(true);  
     }  
 
   /*########################*/
   /* ActionListener Methods */
   /*########################*/

   /*******************/
   /* actionPerformed */
   /*******************/  
   public void actionPerformed(
     ActionEvent ae) 
     { 
      if (clips == null) return;
      
      try
        { runCar(); }
      catch (Exception e)
        { e.printStackTrace(); }
     }
     
   /***********/
   /* runcar */
   /***********/  
   private void runCar() throws Exception
     { 
      String item;
      
      if (isExecuting) return;
      
      clips.reset();      
            
      item = preferredTypeChoices[preferredType.getSelectedIndex()];
      
      if (item.equals("Hatchback"))   
        { clips.assertString("(attribute (name  preferred-type) (value hatcback))"); }
      else if (item.equals("USF"))   
        { clips.assertString("(attribute (name  preferred-type) (value usf))"); }
      else
        { clips.assertString("(attribute (name  preferred-type) (value unknown))"); }

      item = preferredRoadChoices[preferredRoad.getSelectedIndex()];
      if (item.equals("OFFROAD"))   
        { clips.assertString("(attribute (name preferred-road) (value offroad))"); }
      else if (item.equals("HIGHWAY"))   
        { clips.assertString("(attribute (name preferred-road) (value highway))"); }
      else if (item.equals("TRACK"))   
        { clips.assertString("(attribute (name preferred-road) (value track))"); }
      else
        { clips.assertString("(attribute (name preferred-road) (value unknown))"); }
 
      item = preferredDriveChoices[preferredDrive.getSelectedIndex()];
      if (item.equals("4wd"))   
        { clips.assertString("(attribute (name preferred-drive) (value 4wd))"); }
      else if (item.equals("rwd"))   
        { clips.assertString("(attribute (name preferred-drive) (value rwd))"); }
      else if (item.equals("fwd"))   
        { clips.assertString("(attribute (name preferred-drive) (value fwd))"); }
      else
        { clips.assertString("(attribute (name preferred-drive) (value unknown))"); }

      item = mainMarkChoices[mainMark.getSelectedIndex()];
      if (item.equals("WALKSWAGEN") ||
          item.equals("BUGATTI") ||
          item.equals("AUDI"))
        { 
         clips.assertString("(attribute (name main-mark) (value walkswagen))"); 
         clips.assertString("(attribute (name has-mansory) (value no))");
        }
      else if (item.equals("MANSORY"))   
        { 
         clips.assertString("(attribute (name main-mark) (value mersedes))"); 
         clips.assertString("(attribute (name has-mansory) (value yes))");
        }
      else if (item.equals("MERSEDES") ||
               item.equals("POSEIDON"))   
        { 
         clips.assertString("(attribute (name main-mark) (value mersedes))"); 
         clips.assertString("(attribute (name has-mansory) (value no))");
        }
      else if (item.equals("BMW"))   
        { 
         clips.assertString("(attribute (name main-mark) (value bmw))"); 
         clips.assertString("(attribute (name has-mansory) (value no))");
        }
      else if (item.equals("Other"))   
        { 
         clips.assertString("(attribute (name main-mark) (value unknown))"); 
         clips.assertString("(attribute (name has-mansory) (value no))");
        }
      else
        { 
         clips.assertString("(attribute (name main-mark) (value unknown))"); 
         clips.assertString("(attribute (name has-mansory) (value unknown))");
        }

      item = tuningChoices[tuning.getSelectedIndex()];
      if (item.equals("None"))   
        { clips.assertString("(attribute (name has-tuning) (value no))"); }
      else if (item.equals("AMG"))   
        { 
         clips.assertString("(attribute (name has-tuning) (value yes))");
         clips.assertString("(attribute (name tuning) (value amg))");
        }
      else if (item.equals("GARAGE"))   
        { 
         clips.assertString("(attribute (name has-tuning) (value yes))");
         clips.assertString("(attribute (name tuning) (value garage))");
        }
      else if (item.equals("BRABUS"))   
        { 
         clips.assertString("(attribute (name has-tuning) (value yes))");
         clips.assertString("(attribute (name tuning) (value brabus))");
        }
      else if (item.equals("Other"))   
        { 
         clips.assertString("(attribute (name has-tuning) (value yes))");
         clips.assertString("(attribute (name tuning) (value unknown))");
        }
      else
        { 
         clips.assertString("(attribute (name has-tuning) (value unknown))");
         clips.assertString("(attribute (name tuning) (value unknown))");
        }

      item = fuelNames[fuel.getSelectedIndex()];
      if (item.equals("GAS"))   
        { clips.assertString("(attribute (name fuel) (value gas))"); }
      else if (item.equals("BENZINE"))   
        { clips.assertString("(attribute (name fuel) (value benzine))"); }
      else if (item.equals("DIZEL"))   
        { clips.assertString("(attribute (name fuel) (value dizel))"); }
      else
        { clips.assertString("(attribute (name tastiness) (value unknown))"); }
      
      Runnable runThread = 
         new Runnable()
           {
            public void run()
              {
               clips.run();
               
               SwingUtilities.invokeLater(
                  new Runnable()
                    {
                     public void run()
                       {
                        try 
                          { updateCars(); }
                        catch (Exception e)
                          { e.printStackTrace(); }
                       }
                    });
              }
           };
      
      isExecuting = true;
      
      executionThread = new Thread(runThread);
      
      executionThread.start();
     }
     
   /***************/
   /* updatecars */
   /***************/  
   private void updateCars() throws Exception
     { 
      String evalStr = "(CARS::get-car-list)";
                                       
      PrimitiveValue pv = clips.eval(evalStr);
               
      carList.setRowCount(0);
      
      for (int i = 0; i < pv.size(); i++) 
        {
         PrimitiveValue fv = pv.get(i);

         int certainty = fv.getFactSlot("certainty").numberValue().intValue(); 
         
         String carName = fv.getFactSlot("value").stringValue();
                  
         carList.addRow(new Object[] { carName, new Integer(certainty) });
        }  
        
      jfrm.pack();
      
      executionThread = null;
      
      isExecuting = false;
     }     
     
   /********/
   /* main */
   /********/  
   public static void main(String args[])
     {  
      /*===================================================*/
      /* Create the frame on the event dispatching thread. */
      /*===================================================*/
      
      SwingUtilities.invokeLater(
        new Runnable() 
          {  
           public void run() { new CarDemo(); }  
          });   
     }  
  }