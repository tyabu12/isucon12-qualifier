package main

import (
	"log"
	"strings"

	isuports "github.com/isucon/isucon12-qualify/webapp/go"
	"github.com/jmoiron/sqlx"
)

var (
	adminDB *sqlx.DB
)

func main() {
	var err error

	adminDB, err = isuports.ConnectAdminDB()
	if err != nil {
		log.Fatalf("failed to connect db: %v", err)
	}

	tenants := []isuports.TenantRow{}
	if err := adminDB.Select(&tenants, "SELECT id FROM tenant"); err != nil {
		log.Fatalf("error Select tenant: %v", err)
	}
	for _, tenant := range tenants {
		tenantDB, err := isuports.ConnectToTenantSqliteDB(tenant.ID)
		if err != nil {
			log.Fatalf("failed to ConnectToTenantSqliteDB: %v", err)
		}

		players := []isuports.PlayerRow{}
		if err := tenantDB.Select(&players, "SELECT * FROM player WHERE tenant_id = ?", tenant.ID); err != nil {
			log.Fatalf("error select player: %v", err)
		}
		insertPlayer(players)

		competitions := []isuports.CompetitionRow{}
		if err := tenantDB.Select(&competitions, "SELECT * FROM competition WHERE tenant_id = ?", tenant.ID); err != nil {
			log.Fatalf("error select competition: %v", err)
		}
		insertCompetition(competitions)

		insertPlayerScoreSummary(tenantDB, tenant.ID, competitions)
	}
}

func insertCompetition(competitions []isuports.CompetitionRow) {
	insertArgs := []interface{}{}
	for _, competition := range competitions {
		insertArgs = append(insertArgs,
			competition.ID,
			competition.TenantID,
			competition.Title,
			competition.FinishedAt,
			competition.CreatedAt,
			competition.UpdatedAt,
		)
	}

	_, err := adminDB.Exec(
		"INSERT INTO competition (id, tenant_id, title, finished_at, created_at, updated_at) VALUES "+strings.Repeat("(?, ?, ?, ?, ?, ?), ", len(competitions)-1)+"(?, ?, ?, ?, ?, ?)",
		insertArgs...,
	)
	if err != nil {
		log.Fatalf("failed to insert competition: %v", err)
	}
}

func insertPlayer(players []isuports.PlayerRow) {
	insertArgs := []interface{}{}
	for _, player := range players {
		insertArgs = append(insertArgs,
			player.ID,
			player.TenantID,
			player.DisplayName,
			player.IsDisqualified,
			player.CreatedAt,
			player.UpdatedAt,
		)
	}

	_, err := adminDB.Exec(
		"INSERT INTO player (id, tenant_id, display_name, is_disqualified, created_at, updated_at) VALUES "+strings.Repeat("(?, ?, ?, ?, ?, ?), ", len(players)-1)+"(?, ?, ?, ?, ?, ?)",
		insertArgs...,
	)
	if err != nil {
		log.Fatalf("failed to insert player: %v", err)
	}
}

func insertPlayerScoreSummary(tenantDB *sqlx.DB, tenantID int64, competitions []isuports.CompetitionRow) {

	for _, competition := range competitions {
		playerScores := []isuports.PlayerScoreRow{}
		if err := tenantDB.Select(&playerScores, "SELECT * FROM player_score WHERE tenant_id = ? AND competition_id = ? ORDER BY row_num DESC", tenantID, competition.ID); err != nil {
			log.Fatalf("error select player_score: %v", err)
		}

		insertArgs := []interface{}{}
		rowCount := 0
		m := make(map[string]bool)
		for _, playerScore := range playerScores {
			if _, ok := m[playerScore.PlayerID]; ok {
				continue
			}
			m[playerScore.PlayerID] = true
			insertArgs = append(insertArgs,
				playerScore.TenantID,
				playerScore.PlayerID,
				playerScore.CompetitionID,
				playerScore.Score,
				playerScore.RowNum,
			)
			rowCount++
		}

		if rowCount > 0 {
			_, err := adminDB.Exec(
				"INSERT INTO player_score_summary (tenant_id, player_id, competition_id, score, max_row_num) VALUES "+strings.Repeat("(?, ?, ?, ?, ?), ", rowCount-1)+"(?, ?, ?, ?, ?)",
				insertArgs...,
			)
			if err != nil {
				log.Fatalf("failed to insert player_score: %v", err)
			}
		}
	}
}
