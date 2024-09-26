/// Message sent by the CPU to other components like screen, keyboard, ...
/// [ClearScreenMessage] is sent to tell the screen to clear itself
abstract class CPUOutputMessage {
  const CPUOutputMessage();
}

class ClearScreenMessage implements CPUOutputMessage {
  const ClearScreenMessage();
}
