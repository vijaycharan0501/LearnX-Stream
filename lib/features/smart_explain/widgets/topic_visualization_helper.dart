import '../../material_input/models/material_analysis_models.dart';

/// Helper to generate and adapt rich, topic-specific visualization payloads
/// for all 5 LearnX STREAM explanation modalities.
///
/// Ensures that switching modes (e.g. Concept Map, Step-by-Step, Simulation,
/// Guided Chat, Visual Explanation) ALWAYS produces pedagogical data tailored
/// to the CURRENT topic, rather than unrelated fallback placeholders.
class TopicVisualizationHelper {
  TopicVisualizationHelper._();

  /// Normalized topic key detection
  static bool _matches(String topic, List<String> keywords) {
    final lower = topic.toLowerCase();
    return keywords.any((k) => lower.contains(k));
  }

  // ===========================================================================
  // 1. CONCEPT MAP DATA GENERATOR
  // ===========================================================================
  static Map<String, dynamic> getConceptMapData(
    String topic,
    Map<String, dynamic>? originalData,
    List<ConceptItem>? concepts,
  ) {
    // If original data already has rich concept map nodes matching topic, use it
    if (originalData != null &&
        originalData['nodes'] is List &&
        (originalData['nodes'] as List).isNotEmpty) {
      return originalData;
    }

    final cleanTopic = topic.trim().isNotEmpty ? topic.trim() : 'Study Concept';

    // 1. Binary Search / Search / Sorting Algorithms
    if (_matches(cleanTopic, ['binary search', 'search', 'sort', 'algorithm'])) {
      return {
        'root_node': {
          'title': cleanTopic,
          'subtitle': 'Divide-and-conquer logarithmic search algorithm',
        },
        'nodes': [
          {
            'id': 'sorted_array',
            'title': 'Sorted Array Invariant',
            'subtitle': 'Precondition: elements must be sorted ascending',
            'definition': 'The array elements must be sorted so that comparing with the middle value guarantees which half can be discarded.',
            'example': '[10, 20, 30, 40, 50, 60, 70]',
            'parent_id': 'root',
            'level': 1,
            'icon': 'blueprint',
          },
          {
            'id': 'mid_element',
            'title': 'Middle Element (MID)',
            'subtitle': 'Median split index (low + high) / 2',
            'definition': 'The algorithm probes the middle element to divide the search space into two equal halves.',
            'example': 'mid = (0 + 6) / 2 = 3 (Value 40)',
            'parent_id': 'root',
            'level': 1,
            'icon': 'instance',
          },
          {
            'id': 'comparison_logic',
            'title': 'Comparison Logic',
            'subtitle': 'Target vs Middle Value test',
            'definition': 'Evaluates if Target == Mid (found), Target > Mid (search right), or Target < Mid (search left).',
            'example': '60 > 40 -> Target must be in right half',
            'parent_id': 'root',
            'level': 1,
            'icon': 'shapes',
          },
          {
            'id': 'left_discard',
            'title': 'Left Half Elimination',
            'subtitle': 'Low pointer update (low = mid + 1)',
            'definition': 'When target is greater than mid, all elements from index 0 to mid are safely ignored.',
            'example': 'Discard [10, 20, 30, 40], new range is [50, 60, 70]',
            'parent_id': 'comparison_logic',
            'level': 2,
            'icon': 'shapes',
          },
          {
            'id': 'right_discard',
            'title': 'Right Half Elimination',
            'subtitle': 'High pointer update (high = mid - 1)',
            'definition': 'When target is less than mid, all elements from index mid to high are safely ignored.',
            'example': 'Discard right half if target is smaller',
            'parent_id': 'comparison_logic',
            'level': 2,
            'icon': 'shapes',
          },
          {
            'id': 'log_complexity',
            'title': 'Logarithmic Complexity O(log N)',
            'subtitle': 'Search space cut in half every iteration',
            'definition': 'With each check, the remaining possibilities are halved, allowing 1 million items to be searched in ~20 steps.',
            'example': '2^20 ≈ 1,000,000 items in 20 comparisons',
            'parent_id': 'root',
            'level': 1,
            'icon': 'hierarchy',
          },
        ],
        'why_this_works': 'Binary Search works by comparing the target with the middle element and eliminating half the remaining elements each step.',
      };
    }

    // 2. Ohm's Law / Circuits / Physics
    if (_matches(cleanTopic, ['ohm', 'circuit', 'voltage', 'resistance', 'current', 'physics'])) {
      return {
        'root_node': {
          'title': cleanTopic,
          'subtitle': 'Fundamental electrical circuit relationship: V = I × R',
        },
        'nodes': [
          {
            'id': 'voltage',
            'title': 'Voltage (V)',
            'subtitle': 'Electromotive potential difference in Volts (V)',
            'definition': 'The electrical pressure pushing electrons through a conductor.',
            'example': '9V battery, 12V power supply',
            'parent_id': 'root',
            'level': 1,
            'icon': 'blueprint',
          },
          {
            'id': 'current',
            'title': 'Current (I)',
            'subtitle': 'Rate of electrical charge flow in Amperes (A)',
            'definition': 'The quantity of electrons moving through a cross-section per second (I = V / R).',
            'example': '100 mA flowing through bulb',
            'parent_id': 'root',
            'level': 1,
            'icon': 'instance',
          },
          {
            'id': 'resistance',
            'title': 'Resistance (R)',
            'subtitle': 'Opposition to electric current in Ohms (Ω)',
            'definition': 'Material property that restricts electron flow and dissipates energy as heat or light.',
            'example': '100 Ω fixed resistor, filament',
            'parent_id': 'root',
            'level': 1,
            'icon': 'shapes',
          },
          {
            'id': 'proportionality',
            'title': 'Direct & Inverse Laws',
            'subtitle': 'Current is proportional to V, inversely proportional to R',
            'definition': 'Doubling voltage doubles current; doubling resistance cuts current in half.',
            'example': 'V ↑ => I ↑ | R ↑ => I ↓',
            'parent_id': 'root',
            'level': 1,
            'icon': 'hierarchy',
          },
        ],
        'why_this_works': 'Current increases proportionally with Voltage and decreases as Resistance increases.',
      };
    }

    // 3. OOP / Object Oriented Programming & Inheritance
    if (_matches(cleanTopic, ['oop', 'object oriented', 'class', 'inheritance', 'polymorphism', 'encapsulation', 'abstraction'])) {
      return {
        'root_node': {
          'title': cleanTopic,
          'subtitle': 'Object-Oriented Programming & Inheritance Architecture',
        },
        'nodes': [
          {
            'id': 'class',
            'title': 'Class Definition',
            'subtitle': 'Parent Blueprint (Base / Superclass)',
            'definition': 'A blueprint defining common attributes (e.g. speed, fuel) and behaviors (e.g. drive()) shared across all subtypes.',
            'example': 'class Vehicle { int speed; void drive(); }',
            'parent_id': 'root',
            'level': 1,
            'icon': 'blueprint',
          },
          {
            'id': 'object',
            'title': 'Object Instance',
            'subtitle': 'Child Instance (Derived Living Entity)',
            'definition': 'Concrete instantiated living entity and subclasses allocated in heap memory derived from the base class blueprint.',
            'example': 'Vehicle myCar = new ElectricCar();',
            'parent_id': 'root',
            'level': 1,
            'icon': 'instance',
          },
          {
            'id': 'inheritance',
            'title': 'Inheritance',
            'subtitle': 'Inherited Behavior & Code Reuse',
            'definition': 'Mechanism where a child subclass derives attributes and methods from a parent class without repeating duplicate code.',
            'example': 'class ElectricCar extends Vehicle { ... }',
            'parent_id': 'root',
            'level': 1,
            'icon': 'hierarchy',
          },
          {
            'id': 'polymorphism',
            'title': 'Polymorphism',
            'subtitle': 'Method Overriding & Unified Interface',
            'definition': 'Ability of child subclasses to provide specialized implementations of inherited parent methods (e.g. custom acceleration).',
            'example': '@override void drive() { electricDrive(); }',
            'parent_id': 'inheritance',
            'level': 2,
            'icon': 'shapes',
          },
          {
            'id': 'encapsulation',
            'title': 'Encapsulation',
            'subtitle': 'Data Protection & Access Modifiers',
            'definition': 'Restricting direct access to object components using private/protected fields to prevent unauthorized state tampering.',
            'example': 'protected int speed; public int getSpeed()',
            'parent_id': 'root',
            'level': 1,
            'icon': 'lock',
          },
        ],
        'why_this_works': 'Concept maps show how specialized child components inherit attributes and methods from base blueprints without repeating code.',
      };
    }

    // 4. TCP Handshake / Protocols
    if (_matches(cleanTopic, ['tcp', 'handshake', 'network', 'protocol', 'packet'])) {
      return {
        'root_node': {
          'title': cleanTopic,
          'subtitle': 'Reliable transport-layer connection establishment',
        },
        'nodes': [
          {
            'id': 'syn',
            'title': 'SYN (Synchronize)',
            'subtitle': 'Client initiation packet with Sequence Number',
            'definition': 'Client selects randomized Initial Sequence Number (ISN) and asks to connect.',
            'example': 'SYN Seq = 100',
            'parent_id': 'root',
            'level': 1,
            'icon': 'blueprint',
          },
          {
            'id': 'syn_ack',
            'title': 'SYN-ACK Response',
            'subtitle': 'Server acknowledgment and return SYN',
            'definition': 'Server acknowledges Client sequence number and sends its own SYN sequence.',
            'example': 'SYN-ACK Seq = 300, Ack = 101',
            'parent_id': 'root',
            'level': 1,
            'icon': 'instance',
          },
          {
            'id': 'ack',
            'title': 'ACK (Acknowledgment)',
            'subtitle': 'Final confirmation from Client',
            'definition': 'Client confirms receipt of Server sequence number, transitioning socket to ESTABLISHED.',
            'example': 'ACK Ack = 301',
            'parent_id': 'root',
            'level': 1,
            'icon': 'shapes',
          },
          {
            'id': 'duplex',
            'title': 'Full-Duplex Reliability',
            'subtitle': 'Guaranteed two-way transmission',
            'definition': 'Both sides independently verify that the other can transmit and receive data.',
            'example': 'Client <-> Server bi-directional stream',
            'parent_id': 'root',
            'level': 1,
            'icon': 'hierarchy',
          },
        ],
        'why_this_works': 'Concept maps break multi-stage handshakes into clear sequential checkpoints and connection flags.',
      };
    }

    // 5. Photosynthesis / Biological Cycles
    if (_matches(cleanTopic, ['photosynthesis', 'biology', 'plant', 'chloroplast', 'calvin'])) {
      return {
        'root_node': {
          'title': cleanTopic,
          'subtitle': 'Solar energy conversion into chemical energy: 6CO2 + 6H2O -> C6H12O6 + 6O2',
        },
        'nodes': [
          {
            'id': 'light_reaction',
            'title': 'Light-Dependent Reactions',
            'subtitle': 'Thylakoid solar capture and water splitting',
            'definition': 'Chlorophyll absorbs sunlight, splits H2O into Oxygen gas, and generates ATP & NADPH.',
            'example': 'H2O -> O2 + ATP + NADPH',
            'parent_id': 'root',
            'level': 1,
            'icon': 'blueprint',
          },
          {
            'id': 'calvin_cycle',
            'title': 'Calvin Cycle (Light-Independent)',
            'subtitle': 'Stroma carbon fixation into Glucose',
            'definition': 'Uses ATP and NADPH from light reactions to fix CO2 into high-energy Glucose sugar.',
            'example': 'CO2 + ATP + NADPH -> Glucose (C6H12O6)',
            'parent_id': 'root',
            'level': 1,
            'icon': 'instance',
          },
          {
            'id': 'chloroplast',
            'title': 'Chloroplast Organelle',
            'subtitle': 'Double-membrane cellular engine',
            'definition': 'Contains thylakoids and stroma where photosynthetic reactions occur.',
            'example': 'Plant mesophyll cells',
            'parent_id': 'root',
            'level': 1,
            'icon': 'hierarchy',
          },
        ],
        'why_this_works': 'Photosynthesis concept maps visualize how solar photons and water produce oxygen and sugar.',
      };
    }

    // 6. Generic Topic Fallback with extracted concepts
    final nodes = <Map<String, dynamic>>[];
    if (concepts != null && concepts.isNotEmpty) {
      for (int i = 0; i < concepts.length; i++) {
        final c = concepts[i];
        nodes.add({
          'id': 'concept_$i',
          'title': c.name,
          'subtitle': c.formattedType,
          'definition': 'Core conceptual building block of $cleanTopic.',
          'example': 'Key component in mastering $cleanTopic.',
          'parent_id': 'root',
          'level': 1,
          'icon': 'blueprint',
        });
      }
    } else {
      nodes.addAll([
        {
          'id': 'foundation',
          'title': 'Core Foundation',
          'subtitle': 'Fundamental premise of $cleanTopic',
          'definition': 'The primary definition and theoretical basis of $cleanTopic.',
          'example': 'Underlying principle',
          'parent_id': 'root',
          'level': 1,
          'icon': 'blueprint',
        },
        {
          'id': 'mechanism',
          'title': 'Operational Mechanism',
          'subtitle': 'How $cleanTopic functions in practice',
          'definition': 'The internal rules, transformations, and interactions governing $cleanTopic.',
          'example': 'Execution workflow',
          'parent_id': 'root',
          'level': 1,
          'icon': 'instance',
        },
        {
          'id': 'application',
          'title': 'Real-World Impact',
          'subtitle': 'Where $cleanTopic is applied',
          'definition': 'Practical applications, engineering use cases, and efficiency trade-offs.',
          'example': 'Industry application',
          'parent_id': 'root',
          'level': 1,
          'icon': 'hierarchy',
        },
      ]);
    }

    return {
      'root_node': {
        'title': cleanTopic,
        'subtitle': 'Conceptual structure & relationships',
      },
      'nodes': nodes,
      'why_this_works': 'Concept maps organize foundational ideas into clear hierarchical pillars.',
    };
  }

  // ===========================================================================
  // 2. STEP-BY-STEP WORKFLOW DATA GENERATOR
  // ===========================================================================
  static Map<String, dynamic> getStepByStepData(
    String topic,
    Map<String, dynamic>? originalData,
  ) {
    if (originalData != null &&
        originalData['stages'] is List &&
        (originalData['stages'] as List).isNotEmpty) {
      return originalData;
    }

    final cleanTopic = topic.trim().isNotEmpty ? topic.trim() : 'Study Concept';

    // 1. Binary Search
    if (_matches(cleanTopic, ['binary search', 'search', 'sort', 'algorithm'])) {
      return {
        'actors': ['Search Engine', 'Sorted Array'],
        'stages': [
          {
            'stage_number': 1,
            'title': '1. Initialize Boundary Pointers',
            'subtitle': 'Low = 0, High = N - 1',
            'description': 'Set the search window to encompass the entire sorted array. The active search area is [0..length-1].',
            'from_actor': 'Search Engine',
            'to_actor': 'Sorted Array',
            'packet_label': 'Initialize low=0, high=6',
            'state_label': 'WINDOW_INITIALIZED',
            'icon': 'start',
          },
          {
            'stage_number': 2,
            'title': '2. Calculate Middle Element',
            'subtitle': 'Mid = (Low + High) / 2',
            'description': 'Calculate median index: mid = (0 + 6) / 2 = 3. Inspect value arr[3] = 40 against Target = 60.',
            'from_actor': 'Sorted Array',
            'to_actor': 'Search Engine',
            'packet_label': 'arr[3] = 40',
            'state_label': 'MID_EVALUATED',
            'icon': 'sync',
          },
          {
            'stage_number': 3,
            'title': '3. Compare & Halve Range',
            'subtitle': 'Target 60 > 40 -> Eliminate Left Half',
            'description': 'Since 60 > 40 and array is sorted, target cannot be in left half. Adjust low = mid + 1 (low = 4).',
            'from_actor': 'Search Engine',
            'to_actor': 'Sorted Array',
            'packet_label': 'Discard [10..40], new low = 4',
            'state_label': 'HALF_DISCARDED',
            'icon': 'forward',
          },
          {
            'stage_number': 4,
            'title': '4. Target Match Found',
            'subtitle': 'Mid = (4 + 6) / 2 = 5 (arr[5] = 60)',
            'description': 'New middle element arr[5] = 60 matches target 60! Target found in only 2 comparisons (O(log N)).',
            'from_actor': 'Sorted Array',
            'to_actor': 'Search Engine',
            'packet_label': 'Match at Index 5 ✓',
            'state_label': 'TARGET_FOUND',
            'icon': 'complete',
          },
        ],
        'why_this_works': 'Binary Search cuts the remaining search space in half each step, finding targets in O(log N) time.',
      };
    }

    // 2. Ohm's Law
    if (_matches(cleanTopic, ['ohm', 'circuit', 'voltage', 'resistance', 'current', 'physics'])) {
      return {
        'actors': ['Voltage Source', 'Load Resistor'],
        'stages': [
          {
            'stage_number': 1,
            'title': '1. Apply Potential Difference',
            'subtitle': 'Voltage creates electromotive force',
            'description': 'The battery applies electrical pressure (Voltage) across the circuit terminals.',
            'from_actor': 'Voltage Source',
            'to_actor': 'Load Resistor',
            'packet_label': 'Voltage Applied (V)',
            'state_label': 'POTENTIAL_ESTABLISHED',
          },
          {
            'stage_number': 2,
            'title': '2. Encounter Resistance',
            'subtitle': 'Collisions impede electron flow',
            'description': 'Material resistance opposes electron movement, converting kinetic energy into thermal/light energy.',
            'from_actor': 'Load Resistor',
            'to_actor': 'Voltage Source',
            'packet_label': 'Resistance Imposed (R)',
            'state_label': 'IMPEDANCE_ACTIVE',
          },
          {
            'stage_number': 3,
            'title': '3. Steady Current Flow',
            'subtitle': 'I = V / R equilibrium established',
            'description': 'Electrons flow at a steady rate proportional to Voltage and inversely proportional to Resistance.',
            'from_actor': 'Voltage Source',
            'to_actor': 'Load Resistor',
            'packet_label': 'Current (I = V / R)',
            'state_label': 'CURRENT_STABILIZED',
          },
        ],
        'why_this_works': 'Ohm\'s Law describes how current stabilizes when voltage pushes electrons through resistance.',
      };
    }

    // 3. OOP
    if (_matches(cleanTopic, ['oop', 'object oriented', 'class', 'inheritance', 'polymorphism', 'encapsulation'])) {
      return {
        'actors': ['Developer Code', 'Runtime Memory'],
        'stages': [
          {
            'stage_number': 1,
            'title': '1. Declare Class Blueprint',
            'subtitle': 'Define fields and methods template',
            'description': 'Create class definition specifying variables and behavioral methods.',
            'from_actor': 'Developer Code',
            'to_actor': 'Runtime Memory',
            'packet_label': 'class Car { ... }',
            'state_label': 'BLUEPRINT_DEFINED',
          },
          {
            'stage_number': 2,
            'title': '2. Instantiate Living Object',
            'subtitle': 'Heap memory allocation with new',
            'description': 'Constructor executes and allocates discrete state in memory for the instance.',
            'from_actor': 'Runtime Memory',
            'to_actor': 'Developer Code',
            'packet_label': 'myCar = new Car()',
            'state_label': 'OBJECT_INSTANTIATED',
          },
          {
            'stage_number': 3,
            'title': '3. Encapsulated Invocation',
            'subtitle': 'Safe interaction via public interface',
            'description': 'Client code calls methods; private variables remain protected from invalid states.',
            'from_actor': 'Developer Code',
            'to_actor': 'Runtime Memory',
            'packet_label': 'myCar.drive()',
            'state_label': 'BEHAVIOR_EXECUTED',
          },
        ],
        'why_this_works': 'Step-by-step OOP clarifies the journey from code blueprint to living memory object.',
      };
    }

    // 4. TCP Three-Way Handshake
    if (_matches(cleanTopic, ['tcp', 'handshake', 'network', 'protocol'])) {
      return {
        'actors': ['Client', 'Server'],
        'stages': [
          {
            'stage_number': 1,
            'title': '1. SYN (Synchronize)',
            'subtitle': 'Client → Server initiation',
            'description': 'Client sends SYN packet with Initial Sequence Number (ISN=100) requesting connection.',
            'from_actor': 'Client',
            'to_actor': 'Server',
            'packet_label': 'SYN (Seq=100)',
            'direction': 'client_to_server',
            'state_label': 'SYN_SENT',
            'icon': 'start',
          },
          {
            'stage_number': 2,
            'title': '2. SYN-ACK (Acknowledge & Sync)',
            'subtitle': 'Server → Client acknowledgment',
            'description': 'Server acknowledges Client ISN (Ack=101) and sends its own SYN (Seq=300).',
            'from_actor': 'Server',
            'to_actor': 'Client',
            'packet_label': 'SYN-ACK (Seq=300, Ack=101)',
            'direction': 'server_to_client',
            'state_label': 'SYN_RCVD',
            'icon': 'sync',
          },
          {
            'stage_number': 3,
            'title': '3. ACK (Final Acknowledgment)',
            'subtitle': 'Client → Server confirmation',
            'description': 'Client acknowledges Server SYN (Ack=301); reliable full-duplex connection is established.',
            'from_actor': 'Client',
            'to_actor': 'Server',
            'packet_label': 'ACK (Ack=301)',
            'direction': 'client_to_server',
            'state_label': 'ESTABLISHED',
            'icon': 'complete',
          },
        ],
        'why_this_works': 'Breaking protocols into sequential checkpoints clarifies communication.',
      };
    }

    // 5. Photosynthesis Workflow
    if (_matches(cleanTopic, ['photosynthesis', 'biology', 'plant', 'chloroplast', 'calvin'])) {
      return {
        'actors': ['Thylakoid Membrane', 'Stroma'],
        'stages': [
          {
            'stage_number': 1,
            'title': '1. Light Absorption & Photolysis',
            'subtitle': 'Solar capture & water splitting (H2O -> O2)',
            'description': 'Chlorophyll captures solar photons, energizing electrons and splitting water molecules to release oxygen.',
            'from_actor': 'Thylakoid Membrane',
            'to_actor': 'Stroma',
            'packet_label': 'Sunlight + H2O -> O2',
            'state_label': 'PHOTOLYSIS_ACTIVE',
            'icon': 'start',
          },
          {
            'stage_number': 2,
            'title': '2. ATP & NADPH Carrier Synthesis',
            'subtitle': 'Chemical energy currency produced',
            'description': 'Electron transport chain powers ATP Synthase to generate high-energy ATP and NADPH molecules.',
            'from_actor': 'Thylakoid Membrane',
            'to_actor': 'Stroma',
            'packet_label': 'ATP & NADPH Energy Carriers',
            'state_label': 'CARRIERS_CHARGED',
            'icon': 'sync',
          },
          {
            'stage_number': 3,
            'title': '3. Calvin Cycle (Carbon Fixation)',
            'subtitle': 'CO2 converted to Glucose (C6H12O6)',
            'description': 'Stroma enzymes fix atmospheric CO2 with ATP & NADPH energy to synthesize durable Glucose sugar.',
            'from_actor': 'Stroma',
            'to_actor': 'Thylakoid Membrane',
            'packet_label': 'CO2 -> Glucose (C6H12O6) ✓',
            'state_label': 'GLUCOSE_SYNTHESIZED',
            'icon': 'complete',
          },
        ],
        'why_this_works': 'Photosynthesis consists of connected stages transforming solar photons and water into oxygen and glucose.',
      };
    }

    // 6. Sorting Algorithms
    if (_matches(cleanTopic, ['sorting', 'sort', 'bubble sort', 'quick sort', 'merge sort', 'insertion sort'])) {
      return {
        'actors': ['Unsorted Array', 'Sorted Partition'],
        'stages': [
          {
            'stage_number': 1,
            'title': '1. Scan & Compare Adjacent Pairs',
            'subtitle': 'Identify out-of-order inversions',
            'description': 'The algorithm probes pairs of elements in the array to determine if they violate monotonic order.',
            'from_actor': 'Unsorted Array',
            'to_actor': 'Sorted Partition',
            'packet_label': 'Compare arr[i] vs arr[j]',
            'state_label': 'INVERSION_DETECTED',
            'icon': 'start',
          },
          {
            'stage_number': 2,
            'title': '2. Swap / Partition Elements',
            'subtitle': 'Exchange elements into correct relative position',
            'description': 'Inverted items are swapped or partitioned around pivots into their correct sorted segment.',
            'from_actor': 'Unsorted Array',
            'to_actor': 'Sorted Partition',
            'packet_label': 'Swap elements',
            'state_label': 'ELEMENTS_REORDERED',
            'icon': 'sync',
          },
          {
            'stage_number': 3,
            'title': '3. Sorted Invariant Achieved',
            'subtitle': 'All elements monotonically ordered',
            'description': 'All passes complete successfully; the array reaches a verified sorted state.',
            'from_actor': 'Sorted Partition',
            'to_actor': 'Unsorted Array',
            'packet_label': 'Sorted Array ✓',
            'state_label': 'ARRAY_SORTED',
            'icon': 'complete',
          },
        ],
        'why_this_works': 'Step-by-step sorting visualizes comparisons and swaps bringing elements into ordered positions.',
      };
    }

    // Generic Step-by-Step Fallback
    return {
      'actors': ['Input State', 'Output State'],
      'stages': [
        {
          'stage_number': 1,
          'title': '1. Initiation Phase',
          'subtitle': 'Initial conditions for $cleanTopic',
          'description': 'Setup parameters and establish initial baseline for $cleanTopic.',
          'from_actor': 'Input State',
          'to_actor': 'Output State',
          'packet_label': 'Initial Parameters',
          'state_label': 'INITIALIZED',
        },
        {
          'stage_number': 2,
          'title': '2. Core Processing',
          'subtitle': 'Execution transformation',
          'description': 'The central mechanism of $cleanTopic processes inputs and applies rules.',
          'from_actor': 'Output State',
          'to_actor': 'Input State',
          'packet_label': 'Transformation Applied',
          'state_label': 'PROCESSING',
        },
        {
          'stage_number': 3,
          'title': '3. Completion State',
          'subtitle': 'Final output achieved',
          'description': 'Execution terminates successfully with verified results.',
          'from_actor': 'Input State',
          'to_actor': 'Output State',
          'packet_label': 'Result Verified ✓',
          'state_label': 'COMPLETED',
        },
      ],
      'why_this_works': 'Sequential step breakdowns turn complex processes into manageable checkpoints.',
    };
  }

  // ===========================================================================
  // 3. GUIDED CHAT DATA GENERATOR
  // ===========================================================================
  static Map<String, dynamic> getGuidedChatData(
    String topic,
    Map<String, dynamic>? originalData,
  ) {
    if (originalData != null &&
        originalData['steps'] is List &&
        (originalData['steps'] as List).isNotEmpty) {
      return originalData;
    }

    final cleanTopic = topic.trim().isNotEmpty ? topic.trim() : 'Study Concept';

    // 1. Binary Search
    if (_matches(cleanTopic, ['binary search', 'search', 'sort', 'algorithm'])) {
      return {
        'steps': [
          {
            'step_number': 1,
            'title': 'Why must the array be sorted?',
            'explanation': 'Binary Search works by repeatedly comparing the target against the middle element and eliminating half of the search space.',
            'question': 'What would happen if the array was unsorted?',
            'options': [
              'We could still eliminate half the elements each step',
              'Comparing the middle would tell us nothing about which half contains the target',
              'The algorithm would run even faster',
            ],
            'correct_index': 1,
            'feedback': 'Correct! Without sorted order, knowing that target > middle gives zero information about whether the target is in the left or right half.',
          },
          {
            'step_number': 2,
            'title': 'How efficient is Binary Search?',
            'explanation': 'Because the search space is cut in half on every comparison, Binary Search runs in O(log N) logarithmic time.',
            'question': 'In a sorted list of 1,000,000 items, what is the maximum number of comparisons needed?',
            'options': [
              'Approximately 20 comparisons',
              '500,000 comparisons',
              '1,000,000 comparisons',
            ],
            'correct_index': 0,
            'feedback': 'Exactly right! Since 2^20 ≈ 1,048,576, Binary Search finds any target in at most 20 checks!',
          },
        ],
        'why_this_works': 'Conversational discovery highlights the crucial logic behind why sorted order allows logarithmic speed.',
      };
    }

    // 2. Ohm's Law
    if (_matches(cleanTopic, ['ohm', 'circuit', 'voltage', 'resistance', 'current', 'physics'])) {
      return {
        'steps': [
          {
            'step_number': 1,
            'title': 'Voltage, Current, and Resistance',
            'explanation': 'Ohm\'s Law states that electric current (I) is directly proportional to voltage (V) and inversely proportional to resistance (R): I = V / R.',
            'question': 'If you double the Voltage in a circuit with fixed Resistance, what happens to Current?',
            'options': [
              'Current doubles',
              'Current is cut in half',
              'Current remains unchanged',
            ],
            'correct_index': 0,
            'feedback': 'Correct! Higher voltage provides a stronger electromotive push, forcing twice as many electrons through the circuit.',
          },
        ],
        'why_this_works': 'Interactive questioning solidifies the intuitive physical relationship between voltage push and resistance.',
      };
    }

    // 3. OOP
    if (_matches(cleanTopic, ['oop', 'object oriented', 'class', 'inheritance', 'polymorphism'])) {
      return {
        'steps': [
          {
            'step_number': 1,
            'title': 'Class vs Object',
            'explanation': 'In Object-Oriented Programming, classes act as blueprints and objects are concrete instances created from them.',
            'question': 'Which real-world analogy best describes a Class vs an Object?',
            'options': [
              'An Architectural Blueprint vs a Completed House',
              'A Book Page vs a Book Cover',
              'A Gasoline Tank vs an Engine',
            ],
            'correct_index': 0,
            'feedback': 'Spot on! The class defines the structure (blueprint), and you can build many unique houses (objects) from it.',
          },
        ],
        'why_this_works': 'Analogies make object-oriented abstractions concrete and memorable.',
      };
    }

    // 4. TCP Three-Way Handshake
    if (_matches(cleanTopic, ['tcp', 'handshake', 'network', 'protocol'])) {
      return {
        'steps': [
          {
            'step_number': 1,
            'title': 'Why Three Steps?',
            'explanation': 'TCP uses SYN, SYN-ACK, and ACK packets to establish a reliable, full-duplex connection between client and server.',
            'question': 'Why are three packets required instead of just two?',
            'options': [
              'Both client and server must independently verify that the other can send and receive',
              'To encrypt the connection with three keys',
              'Because network routers require a triple-handshake protocol',
            ],
            'correct_index': 0,
            'feedback': 'Correct! Both sides must confirm both sending and receiving capabilities before reliable data transmission begins.',
          },
        ],
        'why_this_works': 'Socratic inquiry clarifies why reliable communication requires mutual two-way confirmation.',
      };
    }

    // Generic Guided Chat Fallback
    return {
      'steps': [
        {
          'step_number': 1,
          'title': 'Understanding $cleanTopic',
          'explanation': '$cleanTopic is a foundational concept designed to solve specific challenges with structured principles.',
          'question': 'What is the most important benefit of understanding $cleanTopic?',
          'options': [
            'It provides structured principles that simplify complex problem solving',
            'It replaces all other methods completely',
            'It only applies to theoretical tests',
          ],
          'correct_index': 0,
          'feedback': 'Correct! Mastering foundational principles turns complicated concepts into intuitive patterns.',
        },
      ],
      'why_this_works': 'Conversational inquiry breaks complex topics into progressive reasoning steps.',
    };
  }

  // ===========================================================================
  // 4. SIMULATION DATA GENERATOR
  // ===========================================================================
  static Map<String, dynamic> getSimulationData(
    String topic,
    Map<String, dynamic>? originalData,
  ) {
    if (originalData != null &&
        originalData['controls'] is List &&
        (originalData['controls'] as List).isNotEmpty) {
      return originalData;
    }

    final cleanTopic = topic.trim().isNotEmpty ? topic.trim() : 'Study Concept';

    // 1. Binary Search
    if (_matches(cleanTopic, ['binary search', 'search', 'sort', 'algorithm'])) {
      return {
        'formula': 'Comparisons ≈ log2(N)',
        'secondary_formula': 'Search Space = N / 2^k',
        'primary_output': {'label': 'Search Efficiency', 'unit': '% Space Left'},
        'controls': [
          {'label': 'Target Number', 'unit': 'val', 'min': 10.0, 'max': 70.0, 'initial': 60.0},
          {'label': 'Array Size (N)', 'unit': 'items', 'min': 7.0, 'max': 128.0, 'initial': 7.0},
        ],
        'items': [10, 20, 30, 40, 50, 60, 70],
        'target': 60,
        'why_this_works': 'Binary Search cuts the remaining search space in half with every comparison.',
      };
    }

    // 2. Ohm's Law
    if (_matches(cleanTopic, ['ohm', 'circuit', 'voltage', 'resistance', 'current', 'physics'])) {
      return {
        'formula': 'V = I × R',
        'secondary_formula': 'I = V / R',
        'primary_output': {'label': 'Current Flow', 'unit': 'mA'},
        'controls': [
          {'label': 'Voltage Push (V)', 'unit': 'V', 'min': 1.0, 'max': 30.0, 'initial': 12.0},
          {'label': 'Circuit Resistance (R)', 'unit': 'Ω', 'min': 10.0, 'max': 600.0, 'initial': 120.0},
        ],
        'why_this_works': 'Current increases proportionally with Voltage and decreases as Resistance increases.',
      };
    }

    // Generic Simulation
    return {
      'formula': 'Output = Input × Efficiency',
      'secondary_formula': 'Efficiency = Output / Input',
      'primary_output': {'label': 'Calculated Output', 'unit': 'units'},
      'controls': [
        {'label': 'Input Parameter A', 'unit': 'pts', 'min': 1.0, 'max': 50.0, 'initial': 10.0},
        {'label': 'System Factor B', 'unit': 'x', 'min': 1.0, 'max': 10.0, 'initial': 2.0},
      ],
      'why_this_works': 'Simulations allow real-time experimentation with the variables of $cleanTopic.',
    };
  }

  // ===========================================================================
  // 5. INTERACTIVE DIAGRAM DATA GENERATOR
  // ===========================================================================
  static Map<String, dynamic> getInteractiveDiagramData(
    String topic,
    Map<String, dynamic>? originalData,
  ) {
    if (originalData != null &&
        (originalData['nodes'] is List || originalData['diagram_modes'] is List)) {
      return originalData;
    }

    final cleanTopic = topic.trim().isNotEmpty ? topic.trim() : 'Study Concept';

    // 1. Relational Databases / SQL JOINs
    if (_matches(cleanTopic, ['join', 'sql', 'database', 'relational', 'table', 'dbms'])) {
      return {
        'title': 'SQL Relational JOINs & Set Theory',
        'subtitle': 'Interactive table set relationships & matching rows',
        'diagram_modes': [
          {
            'id': 'inner_join',
            'label': 'INNER JOIN',
            'description': 'Returns only rows with matching keys in BOTH Table A and Table B.',
            'highlighted_region': 'intersection',
          },
          {
            'id': 'left_join',
            'label': 'LEFT JOIN',
            'description': 'Returns ALL rows from Left Table A, plus matching rows from Right Table B (NULL if no match).',
            'highlighted_region': 'left',
          },
          {
            'id': 'right_join',
            'label': 'RIGHT JOIN',
            'description': 'Returns ALL rows from Right Table B, plus matching rows from Left Table A.',
            'highlighted_region': 'right',
          },
          {
            'id': 'full_outer',
            'label': 'FULL OUTER JOIN',
            'description': 'Returns ALL rows from BOTH tables when there is a match in either table.',
            'highlighted_region': 'all',
          },
        ],
        'nodes': [
          {
            'id': 'table_a',
            'title': 'Table A (Users)',
            'subtitle': 'Primary Left Entity (id, name)',
            'description': 'Holds primary entity records (e.g. Users [id=1: Alice, id=2: Bob, id=3: Charlie]).',
            'example': 'SELECT * FROM Users (id, name)',
            'color': 'teal',
          },
          {
            'id': 'intersection',
            'title': 'Joined Key Match',
            'subtitle': 'Users.id = Orders.user_id',
            'description': 'The matched rows where the foreign key equality predicate evaluates to TRUE.',
            'example': 'ON Users.id = Orders.user_id',
            'color': 'green',
          },
          {
            'id': 'table_b',
            'title': 'Table B (Orders)',
            'subtitle': 'Foreign Key Right Entity (order_id, user_id)',
            'description': 'Holds transaction records referencing users (e.g. Orders [order_101 -> user 1, order_102 -> user 2]).',
            'example': 'SELECT * FROM Orders (order_id, user_id, amount)',
            'color': 'purple',
          },
        ],
        'why_this_works': 'SQL JOINs combine relational tables by matching shared primary and foreign key predicates across Venn sets.',
      };
    }

    // 2. Human Heart & Cardiovascular Circulation
    if (_matches(cleanTopic, ['heart', 'cardiovascular', 'circulation', 'anatomy', 'blood', 'biology'])) {
      return {
        'title': 'Human Heart & Blood Circulation Diagram',
        'subtitle': 'Dual-pump cardiac cycle & oxygen exchange flow',
        'diagram_modes': [
          {
            'id': 'systemic',
            'label': 'Systemic Circuit',
            'description': 'Oxygenated blood pumped from Left Ventricle through Aorta to all body tissues.',
            'highlighted_region': 'left',
          },
          {
            'id': 'pulmonary',
            'label': 'Pulmonary Circuit',
            'description': 'Deoxygenated blood pumped from Right Ventricle to Lungs for O2 replenishment.',
            'highlighted_region': 'right',
          },
          {
            'id': 'complete_cycle',
            'label': 'Complete Cardiac Cycle',
            'description': 'Synchronized diastole & systole pumping blood through all four chambers.',
            'highlighted_region': 'all',
          },
        ],
        'nodes': [
          {
            'id': 'right_heart',
            'title': 'Right Atrium & Ventricle',
            'subtitle': 'Deoxygenated venous blood chamber',
            'description': 'Receives oxygen-poor blood from Superior/Inferior Vena Cava and pumps it into Pulmonary Arteries.',
            'example': 'Tricuspid & Pulmonary Valves',
            'color': 'blue',
          },
          {
            'id': 'lungs_capillaries',
            'title': 'Pulmonary Alveoli / Lungs',
            'subtitle': 'Gas Exchange Interface',
            'description': 'Releases CO2 into exhaled air and binds fresh O2 to hemoglobin molecules.',
            'example': 'Diffusion across alveolar capillary membranes',
            'color': 'purple',
          },
          {
            'id': 'left_heart',
            'title': 'Left Atrium & Ventricle',
            'subtitle': 'Oxygenated systemic pump',
            'description': 'High-pressure muscular chamber that ejects rich oxygenated blood into the systemic Aorta.',
            'example': 'Mitral & Aortic Valves (120/80 mmHg)',
            'color': 'coral',
          },
        ],
        'why_this_works': 'The human heart acts as a synchronized double pump separating oxygenated and deoxygenated blood streams.',
      };
    }

    // 3. Client-Server & Distributed Architecture
    if (_matches(cleanTopic, ['architecture', 'system', 'cloud', 'client', 'server', 'distributed', 'microservice'])) {
      return {
        'title': 'System Architecture & Data Flow',
        'subtitle': 'Interactive multi-tier client, API gateway, and storage topology',
        'diagram_modes': [
          {
            'id': 'read_path',
            'label': 'Read Request Path',
            'description': 'Client -> Edge CDN / Cache -> API Gateway -> Read Replica.',
            'highlighted_region': 'left',
          },
          {
            'id': 'write_path',
            'label': 'Write Transaction Path',
            'description': 'Client -> API Gateway -> Primary Database -> Asynchronous Event Bus.',
            'highlighted_region': 'right',
          },
        ],
        'nodes': [
          {
            'id': 'client_tier',
            'title': 'Client Front-End Tier',
            'subtitle': 'Mobile App / Web SPA',
            'description': 'Dispatches asynchronous REST / GraphQL requests and renders state reactively.',
            'example': 'Flutter / React UI',
            'color': 'teal',
          },
          {
            'id': 'api_gateway',
            'title': 'API Gateway & Services',
            'subtitle': 'Authentication, routing & business logic',
            'description': 'Validates auth tokens, applies rate limits, and orchestrates microservices.',
            'example': 'FastAPI / Node / Go Backend',
            'color': 'purple',
          },
          {
            'id': 'storage_tier',
            'title': 'Data Persistence Tier',
            'subtitle': 'Relational DB & Caching Layer',
            'description': 'Provides ACID durability, read replicas, and fast Redis caching.',
            'example': 'PostgreSQL + Redis Cache',
            'color': 'orange',
          },
        ],
        'why_this_works': 'Tiered architecture isolates presentation, business orchestration, and durable storage for high scalability.',
      };
    }

    // Generic Diagram Fallback
    return {
      'title': '$cleanTopic Architecture & Relationships',
      'subtitle': 'Interactive relational diagram and component dynamics',
      'diagram_modes': [
        {
          'id': 'overview',
          'label': 'Overview Mode',
          'description': 'Inspect all interconnected components and attributes of $cleanTopic.',
          'highlighted_region': 'all',
        },
        {
          'id': 'focus_flow',
          'label': 'Focus Stream',
          'description': 'Isolate primary input-output data transformations.',
          'highlighted_region': 'left',
        },
      ],
      'nodes': [
        {
          'id': 'input_entity',
          'title': 'Source Entity',
          'subtitle': 'Primary input module for $cleanTopic',
          'description': 'The driving source component feeding data into the system.',
          'example': 'Primary Input Element',
          'color': 'teal',
        },
        {
          'id': 'core_rel',
          'title': 'Core Interaction / Transform',
          'subtitle': 'Mediating relationship layer',
          'description': 'Governs the fundamental laws, transitions, and rules of $cleanTopic.',
          'example': 'Interactive Junction Point',
          'color': 'green',
        },
        {
          'id': 'target_entity',
          'title': 'Target Output Entity',
          'subtitle': 'Downstream result component',
          'description': 'The resulting output entity influenced by upstream changes.',
          'example': 'Output / Result State',
          'color': 'purple',
        },
      ],
      'why_this_works': 'Interactive diagrams illustrate how discrete entities interact and exchange signals across boundaries.',
    };
  }
}

