import { vibrator } from '@kit.SensorServiceKit';

@Entry
@Component
struct AllergyHealthPage {



  // Pollen
  @State pollenLevel: string = 'Low';

  // Medication
  @State medRemaining: number = 0;
  @State medActive: boolean = false;
  private medTimer?: number;

  // Symptom
  @State symptomLevel: number = 0;

  // Breathing
  @State breathingText: Resource = $r('app.string.ready_label');
  @State isBreathing: boolean = false;
  @State breathScale: number = 0.6;
  @State pulseScale: number = 0.6;

  private breathTimer?: number;
  private pulseTimer?: number;
  private breathStep: number = 0;



  build() {
    List({ space: 12 }) {
      ListItem() {
        Column({ space: 8 }) {
          Text($r('app.string.app_title'))
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.title_color'))
            .margin({ top: 20 })
        }
        .width('100%')
      }

      // Pollen Section
      ListItem() {
        Column({ space: 8 }) {
          Text($r('app.string.pollen_label'))
            .fontSize(16)
            .fontColor($r('app.color.section_title_color'))

          Row({ space: 10 }) {
            this.pollenButton('Low', $r('app.string.pollen_low'))
            this.pollenButton('Mid', $r('app.string.pollen_mid'))
            this.pollenButton('High', $r('app.string.pollen_high'))
          }

          if (this.pollenLevel === 'High') {
            Text($r('app.string.pollen_warning_high'))
              .fontSize(14)
              .fontColor($r('app.color.error_color'))
              .textAlign(TextAlign.Center)
          }
        }
        .width('100%')
      }

      ListItem() { Divider().strokeWidth(1).color('#333') }

      // Medication Section
      ListItem() {
        Column({ space: 8 }) {
          Text($r('app.string.medication_reminder_label'))
            .fontColor($r('app.color.section_title_color'))
            .fontSize(16)

          if (!this.medActive) {
            Button($r('app.string.medication_set_timer'))
              .borderRadius(20)
              .backgroundColor($r('app.color.success_color'))
              .width(120)
              .height(40)
              .onClick(() => this.startMedication())
          } else {
            Text(`${Math.floor(this.medRemaining / 60)}m ${this.medRemaining % 60}s`)
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
          }
        }
        .width('100%')
      }

      ListItem() { Divider().strokeWidth(1).color('#333') }

      // Symptoms Section
      ListItem() {
        Column({ space: 8 }) {
          Text($r('app.string.symptoms_label'))
            .fontColor($r('app.color.section_title_color'))
            .fontSize(16)

          Slider({
            value: this.symptomLevel,
            min: 0,
            max: 10,
            step: 1
          })
            .width('80%')
            .onChange(v => this.symptomLevel = v)

          Text($r('app.string.level_label', this.symptomLevel))
            .fontSize(14)
            .fontColor(this.symptomColor())
        }
        .width('100%')
      }

      ListItem() { Divider().strokeWidth(1).color('#333') }

      // Breathing Section
      ListItem() {
        Column({ space: 12 }) {
          Text($r('app.string.breathing_label'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.section_title_color'))
            .fontSize(16)

          this.BreathingCircle()

          Text(this.breathingText)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)

          Row({ space: 12 }) {
            Button($r('app.string.start_label'))
              .width(80)
              .height(36)
              .onClick(() => this.startBreathing())

            Button($r('app.string.stop_label'))
              .width(80)
              .height(36)
              .backgroundColor($r('app.color.stop_button_color'))
              .onClick(() => this.stopBreathing())
          }
          .margin({ bottom: 40 })
        }
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .alignListItem(ListItemAlign.Center)
  }
  //Builders

  @Builder
  pollenButton(level: string, label: Resource) {
    Button(label)
      .width(50)
      .height(40)
      .borderRadius(16)
      .fontSize(14)
      .backgroundColor(this.pollenLevel === level ? $r('app.color.active_pollen_color') : $r('app.color.inactive_pollen_color'))
      .onClick(() => this.pollenLevel = level)
  }

  @Builder
  BreathingCircle() {
    Stack() {

      // Pulse ring
      Circle()
        .width(110)
        .height(110)
        .stroke($r('app.color.pulse_color'))
        .strokeWidth(3)
        .opacity(0.4)
        .scale({ x: this.pulseScale, y: this.pulseScale })
        .animation({
          duration: 1500,
          curve: Curve.EaseOut
        })

      // Main breathing circle
      Circle()
        .width(120)
        .height(120)
        .fill($r('app.color.success_color'))
        .scale({ x: this.breathScale, y: this.breathScale })
        .animation({
          duration: 4000,
          curve: Curve.EaseInOut
        })
    }

  }

  //Functions

  startMedication() {
    this.medRemaining = 30 * 60;
    this.medActive = true;
    clearInterval(this.medTimer);

    this.medTimer = setInterval(() => {
      if (this.medRemaining > 0) {
        this.medRemaining--;
      } else {
        clearInterval(this.medTimer);
        this.medActive = false;
        console.info('Take your medication');
      }
    }, 1000);
  }

  symptomColor(): Resource {
    if (this.symptomLevel <= 3) {return $r('app.color.success_color')}
    if (this.symptomLevel <= 6) {return $r('app.color.warning_color')}
    return $r('app.color.error_color');
  }

  startBreathing() {
    if (this.isBreathing){
      return;
    }

    this.isBreathing = true;
    this.breathingText = $r('app.string.inhale_label')
    this.breathScale = 1.0;

    clearInterval(this.breathTimer);
    clearInterval(this.pulseTimer);

    this.breathStep = 0;

    //Breathing cycle
    this.breathTimer = setInterval(() => {
      switch (this.breathStep % 3) {
        case 0:
          this.breathingText = $r('app.string.inhale_label');
          this.breathScale = 1.0;
          this.triggerHaptic('watch_soft_heavy');
          break;
        case 1:
          this.breathingText = $r('app.string.hold_label');
          this.breathScale = 1.0;
          break;
        case 2:
          this.breathingText = $r('app.string.exhale_label');
          this.breathScale = 0.6;
          this.triggerHaptic('watch_soft_light');
          break;
      }
      this.breathStep++;
    }, 4000);

    //Pulse effect
    this.pulseTimer = setInterval(() => {
      this.pulseScale = 1.2;
      setTimeout(() => {
        this.pulseScale = this.breathScale;
      }, 300);
    }, 1500);
  }

  stopBreathing(){
    this.isBreathing = false;

    clearInterval(this.breathTimer);
    clearInterval(this.pulseTimer);

    this.breathingText = $r('app.string.ready_label');
    this.breathScale = 0.6;
    this.pulseScale = 0.6
  }

  triggerHaptic(effect: string) {
    try {
      vibrator.startVibration({
        type: 'preset',
        effectId: effect,
        count: 1,
      }, {
        usage: 'alarm',
        intensity: 100
      }, (error) => {
        if (error) {
          console.error(`Vibration failed. Code: ${error.code}, message: ${error.message}`);
          return;
        }
        console.info('Vibration succeeded.');
      });
    } catch (err) {
      console.error(`An unexpected error occurred. Code: ${err.code}, message: ${err.message}`);
    }
  }
}