import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { ThemeBook, MoveItem } from '../../models/TuceModels'
import { MoveLibrary } from '../../services/MoveLibrary'
import { TuceStore } from '../../services/TuceStore'
import { TuceNav } from '../../services/TuceNav'

class ThemePickRow {
  id: string = ''
  name: string = ''
}

@Component
export struct ThemeBookEditorPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop bookId: string = ''
  @State name: string = ''
  @State rows: ThemePickRow[] = []
  @State catalog: MoveItem[] = []
  @State errorText: string = ''

  aboutToAppear(): void {
    this.catalog = MoveLibrary.all()
    void this.load()
  }

  private async load(): Promise<void> {
    if (this.bookId.length === 0) {
      this.name = '我的主题册'
      return
    }
    const list = await TuceStore.themes()
    for (const it of list) {
      if (it.id === this.bookId) {
        this.name = it.name
        const ids = MoveLibrary.splitIds(it.moveIds)
        const next: ThemePickRow[] = []
        for (const id of ids) {
          const m = MoveLibrary.find(id)
          if (m !== undefined) {
            const row = new ThemePickRow()
            row.id = m.id
            row.name = m.name
            next.push(row)
          }
        }
        this.rows = next
      }
    }
  }

  private addId(id: string): void {
    for (const r of this.rows) {
      if (r.id === id) {
        return
      }
    }
    const m = MoveLibrary.find(id)
    if (m === undefined) {
      return
    }
    const row = new ThemePickRow()
    row.id = m.id
    row.name = m.name
    const next: ThemePickRow[] = []
    for (const it of this.rows) {
      next.push(it)
    }
    next.push(row)
    this.rows = next
  }

  private removeAt(index: number): void {
    const next: ThemePickRow[] = []
    let i = 0
    for (const it of this.rows) {
      if (i !== index) {
        next.push(it)
      }
      i++
    }
    this.rows = next
  }

  private async save(): Promise<void> {
    if (this.name.trim().length === 0) {
      this.errorText = '请填写主题册名称'
      return
    }
    if (this.rows.length === 0) {
      this.errorText = '至少选择 1 个动作'
      return
    }
    const book = new ThemeBook()
    book.id = this.bookId.length > 0 ? this.bookId : TuceStore.newId('theme')
    book.name = this.name.trim()
    const ids: string[] = []
    for (const r of this.rows) {
      ids.push(r.id)
    }
    book.moveIds = ids.join('|')
    await TuceStore.saveTheme(book)
    TuceNav.bump()
    TuceNav.close()
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s3 }) {
        TextInput({ text: this.name, placeholder: '主题册名称，如晚间放松册' })
          .onChange((v: string): void => { this.name = v })

        Text('已选动作')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        ForEach(this.rows, (row: ThemePickRow, index: number) => {
          Row({ space: Theme.space.s2 }) {
            Text(`${index + 1}. ${row.name}`)
              .fontSize(Theme.type.bodyS)
              .layoutWeight(1)
            Row() {
              Text('移除')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().danger)
            }
            .width(44)
            .height(36)
            .justifyContent(FlexAlign.Center)
            .onClick((): void => { this.removeAt(index) })
          }
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.sm)
        }, (row: ThemePickRow) => row.id)

        Text('从图鉴添加')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        ForEach(this.catalog, (m: MoveItem) => {
          Row() {
            Text(`${m.category} · ${m.name}`)
              .fontSize(Theme.type.bodyS)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceSubtle : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.sm)
          .onClick((): void => { this.addId(m.id) })
        }, (m: MoveItem) => m.id)

        if (this.errorText.length > 0) {
          Text(this.errorText)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().danger)
        }
        AppButton({ label: '保存主题册', variant: 'primary', onTap: (): void => { void this.save() } })
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s2,
        bottom: Theme.space.s10
      })
    }
    .width('100%')
    .height('100%')
    .edgeEffect(EdgeEffect.Spring)
    .scrollBar(BarState.Auto)
  }
}
